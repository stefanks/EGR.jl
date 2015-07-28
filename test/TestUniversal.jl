using EGR
using Redis

println("TestUniversal")

createOracleOutputLevel = 1
numEquivalentPasses = 0.9
algOutputLevel = 2
maxOutputNum=20

myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
	
	myOptss(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)
	
	chunkSize  = 2
	u = (k,I)-> k
	alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))),  myOptss(0), onlyAddBeta1(u,"uTest",numVars, chunkSize,false), myOutputOpts, myWriteFunction, myREfunction)
	s = (k,I)-> int(floor(k==0 ? 0 : k))
	alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))),  myOptss(0), onlyUpdateBeta1(s, "sTest", numVars, int(floor(numTrainingPoints/chunkSize)), chunkSize,false), myOutputOpts, myWriteFunction, myREfunction)
	alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))),  myOptss(0), uLinBeta1(1.0,numVars, chunkSize,false), myOutputOpts, myWriteFunction, myREfunction)
	alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))),  myOptss(0), uQuadBeta1(1.0,numVars, chunkSize,false), myOutputOpts, myWriteFunction, myREfunction)
	alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))),  myOptss(0), uExpBeta1(1.0,2.0,numVars, chunkSize,false), myOutputOpts, myWriteFunction, myREfunction)
	
end



println("TestUniversal successful!")
println()