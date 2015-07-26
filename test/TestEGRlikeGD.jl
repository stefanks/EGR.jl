using Base.Test
using EGR

println("TestEGRlikeGD")

createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=20
stepOutputLevel=0

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	print(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
	myOpts(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=stepOutputLevel)
			
	
	getFullGradient(W) = gradientOracle(W)
			
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromGD) = alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))), myOpts(0),GDsd( "GD.a=1") , myOutputOpts, myWriteFunction, myREfunction)

	s(k,I) = sLikeGd(k,numTrainingPoints)
	u(k,I) =  uLikeGd(k,numTrainingPoints)
	beta(k) =1 
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGRgd) = alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))), myOpts(0), EGRsd(s,u,beta, numVars, csDataType, "EGR.GDlike.a=1"), myOutputOpts, myWriteFunction, myREfunction)
		
		
	relError = norm(xFromEGRgd-xFromGD)/norm(xFromGD)
		
	println(" relError between EGR and GD = $relError")
	if relError>1e-13
		error("GD and EGR do not coincide")
	end
end



println("TestEGRlikeGD successful!")
println()