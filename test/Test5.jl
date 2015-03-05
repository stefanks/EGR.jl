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
end



