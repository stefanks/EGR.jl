using Base.Test
using EGR

println("TestEGRlikeGD")

createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	print(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
	myOpts(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
			
	stepSize(k)=1.0
	
	getFullGradient(W) = gradientOracle(W)
			
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromGD) = alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0),GDsd( "GD","GD a=1") , myOutputOpts, myWriteFunction, myREfunction)
	
	
	# thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))
	# Problem(L2reg, datasetHT["name"], LossFunctionString, ()->0, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)),(j)->getSampleFunctionAt(j,gradientOracle,restoreGradient))
	
		
	s(k,I) = sLikeGd(k,numTrainingPoints)
	u(k,I) =  uLikeGd(k,numTrainingPoints)
	beta(k) =1 
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGRgd) = alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0), EGRsd(s,u,beta, numVars, csDataType, "EGR.GDlike", "EGR.GDlike a=1"), myOutputOpts, myWriteFunction, myREfunction)
		
		
	relError = norm(xFromEGRgd-xFromGD)/norm(xFromGD)
		
	println(" relError between EGR and GD = $relError")
	if relError>1e-13
		error("GD and EGR do not coincide")
	end
end



println("TestEGRlikeGD successful!")
println()