using Base.Test
using EGR

println("TestSSVRG")

createOracleOutputLevel = 1
numEquivalentPasses = 0.5
algOutputLevel = 0
maxOutputNum=20

sLikeGd(k,numTP) = k==0 ? 0 : numTP
uLikeGd(k,numTP) = k==0 ? numTP : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
			
	maxG  = Int(round(numEquivalentPasses*numTP))
	
	expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1
	
	myOutputOpts =  OutputOpts(myOutputter,expIndices)
	myOptss(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)
	k(k,mtilde)=k+1
	m=10
	alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))),  myOptss(0), SSVRG(k,m,numVars), myOutputOpts, myWriteFunction)
end



println("TestSSVRG successful!")
println()