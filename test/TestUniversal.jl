using EGR
using Redis

println("TestUniversal")

createOracleOutputLevel = 1
numEquivalentPasses = 0.9
algOutputLevel = 2
maxOutputNum=20

myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
			
	maxG  = Int(round(numEquivalentPasses*numTP))
	
	expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1
	
	myOutputOpts =  OutputOpts(myOutputter,expIndices)
	
	myOptss(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)
	
	chunkSize  = 2
	u = (k,I)-> k
	alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))),  myOptss(0), onlyAddBeta1(u,"uTest",numVars, chunkSize,false), myOutputOpts, myWriteFunction)
	s = (k,I)-> Int(floor(k==0 ? 0 : k))
	alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))),  myOptss(0), onlyUpdateBeta1(s, "sTest", numVars, int(floor(numTP/chunkSize)), chunkSize,false), myOutputOpts, myWriteFunction)
	alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))),  myOptss(0), uLinBeta1(1.0,numVars, chunkSize,false), myOutputOpts, myWriteFunction)
	alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))),  myOptss(0), uQuadBeta1(1.0,numVars, chunkSize,false), myOutputOpts, myWriteFunction)
	alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))),  myOptss(0), uExpBeta1(2.0,numVars, chunkSize,false), myOutputOpts, myWriteFunction)
	
end



println("TestUniversal successful!")
println()