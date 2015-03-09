using Base.Test
using EGR
using Redis

client = RedisConnection()

run(`redis-cli keys "Test*"` |> `xargs redis-cli del`)

createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 2
maxOutputNum=20
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0

myREfunction(problem, opts, sd, wantOutputs) = returnIfExists(client, problem, opts, sd, wantOutputs,1)
myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, fromOutputsFunction)


thisOracle=Oracles[1]
				
(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) = thisOracle
		
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
	
stepSize(k)=1.0
		
s(k,I) = 0
u(k,I) = 1
beta(k) = 1
			
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts(0), EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)

alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts(0), EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)

myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts(0), EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)

myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=100000, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts(0), EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)

alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts(0), EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)

myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=100001, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum, logarithmic = false)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts(0), EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike"), myOutputOpts, myWriteFunction, myREfunction)