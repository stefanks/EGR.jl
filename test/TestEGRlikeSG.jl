using Base.Test
using EGR

println("TestEGRlikeSG")

createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem,dims) in Oracles
	
	print(" $thisDataName $LossFunctionString L2reg = $L2reg")
		
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
	myOpts(stepSizePower) = Opts(zeros(dims); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
		
	s(k,I) = 0
	u(k,I) = 1
	beta(k) = 1
			
	a = Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle, restoreGradient))
	b = Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle, restoreGradient))
	
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGR) = alg(thisProblem(a)	, myOpts(0), EGRsd(s,u,beta,numVars, csDataType,  "EGR.SGlike", "EGR.SGlike a=1"), myOutputOpts, myWriteFunction, myREfunction)
	
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromSG)  = alg(thisProblem(b)	, myOpts(0), SGsd( "SG", "SG a=1")                                               , myOutputOpts, myWriteFunction, myREfunction)
		
		
		
		
	relError = norm(xFromEGR-xFromSG)/norm(xFromSG)
		
	println(" relError between EGR and SG = $relError")
	if relError>1e-13
		error("SG and EGR do not coincide")
	end
			
end


println("TestEGRlikeSG successful!")
println()