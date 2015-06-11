using Base.Test
using EGR

println("TestSteps")

createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 10
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
	myOpts(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=1)
	k(k)=k+1
	m=10
	alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle, restoreGradient))),  myOpts(0), SSVRGsd(k,m,numVars, "ssvrg","ssvrg"), myOutputOpts, myWriteFunction, myREfunction)
end



println("TestSteps successful!")
println()