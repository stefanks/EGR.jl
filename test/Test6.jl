using Base.Test
using EGR



findBests = [
"f", 
"pcc"
]


createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE

sds = [
(n,ntp,dt)->EGRexp(1.0,100.0,n,ntp, (k)->1, false, dt,"alg2.s_k=u_k=(101/100)^(k-1).b_k=1"),
(n,ntp,dt)->EGRsd((k,I)-> k >I ? I : k, (k,I)->k+1 > ntp - I ? ntp-I : k+1, (k)->1, n, true, dt, "alg4.s_k=k.u_k=k+1.b_k=1"),
(n,ntp,dt)->SGsd( "SG")
]


myREfunction(problem, opts, sd, wantOutputs) = returnIfExists(client, problem, opts, sd, wantOutputs,0)
myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, fromOutputsFunction)


for thisProblem in Problems
			
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
			
				
		algForSearch(stepSizePower) =alg(, myOpts(stepSizePower), sd(numVars,numTrainingPoints,csDataType), myOutputOpts, myWriteFunction, myREfunction)

		findBests = [((res)->getF(res,maxG),0.0),((res)->getPCC(res,maxG),-1.0), ((res)->getMCC(res,maxG),-1.0)]
				
		for findBest in findBests
			findBestStepsizeFactor(algForSearch,findBest...; outputLevel=1)
		end
				
	end
end



