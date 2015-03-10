using Base.Test
using EGR
using Redis


println("TestRedisRuns")

client = RedisConnection()

run(`redis-cli keys "Test*"` |> `xargs redis-cli del`);


createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=5
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE


myREfunction(problem, opts, sd, expIndices) = returnIfExists(client, problem, opts, sd, expIndices; outputLevel = 0)
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, origWant, fromOutputsFunction; outputLevel = 0)

thisOracle=Oracles[1]
				
(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem,dims) = thisOracle
		
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
stepSize(k)=1.0
		
s(k,I) = 0
u(k,I) = 2
beta(k) = 1

thisSD = EGRsd(s,u,beta,numVars, true, csDataType,  "EGR.SGlike")

longKey = thisDataName*":"*LossFunctionString*":"*string(L2reg)*":"thisSD.stepString*":"*"const"*":0"
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))



myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=20, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts,thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts,thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=100000, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=100001, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum, logarithmic = false)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=99, logarithmic = false)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(dims); stepSizeFunction=constStepSize, stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=99, logarithmic = false)
alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))


println("TestRedisRuns successful!")
println()