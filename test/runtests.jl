using EGR
using Redis

try 
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0

println("Starting Redis connection")
client = RedisConnection();

run(`redis-cli keys "TestToy:*"` |> `xargs redis-cli del`)
run(`redis-cli keys "TestAgaricus:*"` |> `xargs redis-cli del`)

testProblems = ["TestToy"]

findBests = [
"f", 
"pcc"
]

L2regs=[
false,
true
]

createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE

sds = [
(n,ntp,dt)->EGRexp(1.0,10.0,n,ntp, (k)->1, false, dt, "alg2.s_k=u_k=(11/10)^(k-1).b_k=1"),
(n,ntp,dt)->EGRexp(1.0,10.0,n,ntp, (k)->1, true, dt, "alg4.s_k=u_k=(11/10)^(k-1).b_k=1"),
(n,ntp,dt)->EGRexp(1.0,100.0,n,ntp, (k)->1, false, dt,"alg2.s_k=u_k=(101/100)^(k-1).b_k=1"),
(n,ntp,dt)->EGRexp(1.0,100.0,n,ntp, (k)->1, true, dt, "alg4.s_k=u_k=(101/100)^(k-1).b_k=1"),
(n,ntp,dt)->EGRexp(1.0,1000.0,n,ntp, (k)->1, false, dt,"alg2.s_k=u_k=(1001/1000)^(k-1).b_k=1"),
(n,ntp,dt)->EGRexp(1.0,1000.0,n,ntp, (k)->1, true,  dt,"alg4.s_k=u_k=(1001/1000)^(k-1).b_k=1"),
(n,ntp,dt)->EGRsd((k,I)-> k >I ? I : k, (k,I)->k+1 > ntp - I ? ntp-I : k+1, (k)->1, n, false, dt,"alg2.s_k=k.u_k=k+1.b_k=1"),
(n,ntp,dt)->EGRsd((k,I)-> k >I ? I : k, (k,I)->k+1 > ntp - I ? ntp-I : k+1, (k)->1, n, true, dt, "alg4.s_k=k.u_k=k+1.b_k=1"),
(n,ntp,dt)->SGsd( "SG")
]

createOracleFunctionArray = 
[
(features, labels, L2reg, outputLevel) -> createBLOracles(features, labels, Set([1.0]), L2reg, outputLevel),
(features, labels, L2reg, outputLevel) -> createMLOracles(features, labels, L2reg, outputLevel)
]


myREfunction(problem, opts, sd, wantOutputs) = returnIfExists(client, problem, opts, sd, wantOutputs,0)
myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, fromOutputsFunction)

for testProblem in testProblems

	(numDatapoints,minFeatureInd,numFeatures,numTotal,minfeature,maxfeature,numClasses) = getStats("data/"*testProblem*"/"*testProblem)
	println("Number of datapoints = $numDatapoints")
	println("minFeatureInd   = $minFeatureInd")
	println("number of features   = $numFeatures")
	println("numTotal   = $(numTotal)")
	println("sparsity   = $(numTotal/(numDatapoints*numFeatures))")
	println("minfeature   = $minfeature")
	println("maxfeature   = $maxfeature")
	println("numClasses   = $numClasses")

	(features, labels) = readData("data/"*testProblem*"/"*testProblem, (numDatapoints,numFeatures), minFeatureInd)

	# NORMALIZE FEATURES!!!
	if (numTotal/(numDatapoints*numFeatures))>0.99 && (minfeature<-1.01 || maxfeature>1.01)
		minfeature=typemax(Int)
		maxfeature=typemin(Int)
		for j in 1:numFeatures
			thismax = maximum(features[:,j])
			thismin = minimum(features[:,j])
			features[:,j] =(2* features[:,j]-thismax-thismin)/(thismax-thismin)
			minfeature=min(minfeature, minimum(features[:,j] ))
			maxfeature=max(maxfeature, maximum(features[:,j] ))
		end
		println("After normalization")
		println("minfeature   = $minfeature")
		println("maxfeature   = $maxfeature")
	end

	Redis.hmset(client, testProblem, {"name" => testProblem, "path" => "data/"*testProblem*"/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" =>numTotal })

	println("Writing binary file")

	writeBin("data/"*testProblem*"/"*testProblem*".bin", features, labels)

	datasetHT=Redis.hgetall(client,testProblem)

	println("Reading binary file")

	(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin", int(datasetHT["numDatapoints"]), int(datasetHT["numFeatures"]))

	for createOracleFunctions in createOracleFunctionArray
		for L2reg in L2regs
			
			(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient, csDataType, outputStringHeader,  LossFunctionString,numOutputsFromOutputsFunction ) = createOracleFunctions(features, labels, L2reg, createOracleOutputLevel)
			
			myOutputter = Outputter(outputsFunction, outputStringHeader,numOutputsFromOutputsFunction)
			
			myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
			maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
			myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
			
			VerifyGradient(numVars,gradientOracle,numTrainingPoints; outputLevel=2)
			VerifyRestoration(numVars,gradientOracle,restoreGradient; outputLevel=2)
			
			#By now the oracles are created. 
			# From now on only concerned with the algorithm
		
			println("If s(k) = 0 and then numTrainingPoints, u(k) = numTrainingPoints, then 0 , gamma is natural, then egrs is equivalent to gd!!!")
		
			stepSize(k)=1.0
	

			getFullGradient(W) = gradientOracle(W)
			# Problem(L2reg, datasetHT["name"], LossFunctionString, getFullGradient, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))
			#  myOpts(0)
			#  GDsd( "GD")
			#  myOutputOpts
			#   myWriteFunction
			#    myREfunction
			
			(outString, results_k, results_gnum,results_fromOutputsFunction,xFromGD) = alg(Problem(L2reg, datasetHT["name"], LossFunctionString, getFullGradient, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0),GDsd( "GD") , myOutputOpts, myWriteFunction, myREfunction)
	
		
			s(k,I) = sLikeGd(k,numTrainingPoints)
			u(k,I) =  uLikeGd(k,numTrainingPoints)
			beta(k) =1
			(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGRgd) = alg(Problem(L2reg, datasetHT["name"], LossFunctionString, ()->0, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0), EGRsd(s,u,beta, numVars, true, csDataType, "EGR.GDlike"), myOutputOpts, myWriteFunction, myREfunction)
		
		
			relError = norm(xFromEGRgd-xFromGD)/norm(xFromGD)
		
			println("relError between EGR and GD = $relError")
			if relError>1e-13
				error("GD and EGR do not coincide")
			end
			
		
			println("If s(k) = 0, u(k) = 1, then 0, then egrs is equivalent to sg!!!")
			
			
			stepSize(k)=1.0
		
			thismaxG = numTrainingPoints
			
			(outString, results_k, results_gnum,results_fromOutputsFunction,xFromSG) = alg(Problem(L2reg, datasetHT["name"], LossFunctionString, ()->0, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0),SGsd( "SG") , myOutputOpts, myWriteFunction, myREfunction)
		
		
			s(k,I) = 0
			u(k,I) = 1
			beta(k) = 1
			
			(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGR) = alg(Problem(L2reg, datasetHT["name"], LossFunctionString, ()->0, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0), EGRsd(s,u,beta, numVars, true,csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)
		
		
			relError = norm(xFromEGR-xFromSG)/norm(xFromSG)
		
			println("relError between EGR and SG = $relError")
			if relError>1e-13
				error("SG and EGR do not coincide")
			end
			
			
			
			
			
			

			for sd in sds
			
				
				algForSearch(stepSizePower) =alg(Problem(L2reg, datasetHT["name"], LossFunctionString, ()->0, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(stepSizePower), sd(numVars,numTrainingPoints,csDataType), myOutputOpts, myWriteFunction, myREfunction)

				findBests = [((res)->getF(res,maxG),0.0),((res)->getPCC(res,maxG),-1.0), ((res)->getMCC(res,maxG),-1.0)]
				
				for findBest in findBests
					findBestStepsizeFactor(algForSearch,findBest...; outputLevel=1)
				end
				
			end
		end
	end
end














#
#
#
# println("Testing MinusPlusOneVector")
#
# a=MinusPlusOneVector([1,1,-1])
# b=MinusPlusOneVector([1,1,-1.0])
# c=MinusPlusOneVector([1,1,-1],Set([-1]))
# println(a[1])
# println(b[2:3])
# println(c[[1,3]])
# println(length(a))