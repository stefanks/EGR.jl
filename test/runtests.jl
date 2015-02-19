using Base.Test
using EGR
using Redis
try 
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0

# testProblems=["TestToy","TestAgaricus"]
testProblems=["TestToy"]

L2regs =  [0.0, 1e-10, 1e-5,1]

findBests = ["f", "pcc"]

numEquivalentPasses = 5

stepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE

createOracleFunctionArray = 
[
(features, labels, L2reg, outputLevel) -> createBLOracles(features, labels, Set([1.0]), L2reg, outputLevel),
(features, labels, L2reg, outputLevel) -> createMLOracles(features, labels, L2reg, outputLevel)
]

myWriteFunction(stepSizeFactor::Float64) = "ok"
myWriteFunction(writeLoc, k, gnum, fromOutputsFunction, x) = "ok"

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

	println("Starting Redis connection")
	client = RedisConnection();
	Redis.hmset(client, testProblem, {"name" => testProblem, "path" => "data/"*testProblem*"/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" =>numTotal })

	println("Writing binary file")

	writeBin("data/"*testProblem*"/"*testProblem*".bin", features, labels)

	datasetHT=Redis.hgetall(client,testProblem)

	println("Reading binary file")

	(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin", int(datasetHT["numDatapoints"]), int(datasetHT["numFeatures"]))

	for L2reg in L2regs
		println("L2reg = $L2reg")
		
		
		for createOracleFunctions in createOracleFunctionArray
		
			(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient,outputStringHeader) = createOracleFunctions(features, labels, L2reg, 1)

			VerifyGradient(numVars,gradientOracle,numTrainingPoints; outputLevel=2)
			VerifyRestoration(numVars,gradientOracle,restoreGradient; outputLevel=2)
			
			getNextSampleFunction = Task(() -> getSequential(numTrainingPoints,gradientOracle,restoreGradient))
			

		
			println("If s(k) = 0 and then numTrainingPoints, u(k) = numTrainingPoints, then 0 , gamma is natural, then egrs is equivalent to gd!!!")
		
			stepSize(k)=1.0
		
			maxG = 10*numTrainingPoints

			getFullGradient(W) = gradientOracle(W)
			(outString, results_k, results_gnum,results_fromOutputsFunction, results_x) = alg(Opts(zeros(numVars),stepSize; maxG=numEquivalentPasses*numTrainingPoints), GDsd(getFullGradient, numTrainingPoints,"GD"), OutputOpts(outputsFunction, outputStringHeader;outputLevel=2,maxOutputNum=11),myWriteFunction)
		
			xFromGD = results_x[end]
		
			s(k,I) = sLikeGd(k,numTrainingPoints)
			u(k,I) =  uLikeGd(k,numTrainingPoints)
			beta(k) =1
			(outString, results_k, results_gnum,results_fromOutputsFunction, results_x) = alg(Opts(zeros(numVars),stepSize; maxG=numEquivalentPasses*numTrainingPoints), EGRsd(s, u, beta, getNextSampleFunction,numVars,"EGR gd-like"), OutputOpts(outputsFunction, outputStringHeader;outputLevel=2,maxOutputNum=11),myWriteFunction)
		
			xFromEGR = results_x[end]
		
			relError = norm(xFromEGR-xFromGD)/norm(xFromGD)
		
			println("relError between EGR and GD = $relError")
			if relError>1e-13
				error("GD and EGR do not coincide")
			end
			
			# sds = [EGRsd((k,I)->k, (k,I)->k+1, (k)->1, getNextSampleFunction,numVars), SGsd(getNextSampleFunction)]
			sds = [EGRsd((k,I)->k, (k,I)->k+1, (k)->1, getNextSampleFunction,numVars,"EGR.s(k)=k.u(k)=k+1.beta(k)=1") , SGsd(getNextSampleFunction,"SG"),GDsd(getFullGradient,numTrainingPoints,"GD")]
		
			for sd in sds
				println("sd = $(sd.stepString)")

				algForSearch(stepSize) = alg(Opts(zeros(numVars), stepSize; maxG=int(round(numEquivalentPasses*numTrainingPoints))), sd, OutputOpts(outputsFunction, outputStringHeader; outputLevel=0, maxOutputNum=11), myWriteFunction)[4][end][2]
				
				println("Successfully defined algForSearch")
			
				for findBest in findBests
					findBestStepsizeFactor(findBest, stepSize, algForSearch; outputLevel=2)
				end
			end
		end
	end
end






















println("Testing MinusPlusOneVector")

a=MinusPlusOneVector([1,1,-1])
b=MinusPlusOneVector([1,1,-1.0])
c=MinusPlusOneVector([1,1,-1],Set([-1]))	
println(a[1])
println(b[2:3])
println(c[[1,3]])
println(length(a))