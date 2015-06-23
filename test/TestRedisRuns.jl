using Base.Test
using EGR
using Redis


println("TestRedisRuns")

client = RedisConnection()

run(`redis-cli keys "Test*"` |> `xargs redis-cli del`);


createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 2
maxOutputNum=5


myREfunction(problem, opts, sd, expIndices,n) = returnIfExists(client, problem, opts, sd, expIndices,n; outputLevel = 0)
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, origWant, fromOutputsFunction; outputLevel = 0)

thisOracle=Oracles[1]
				
(gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) = thisOracle
		
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
maxG  = int(round(numEquivalentPasses*numTrainingPoints))
		
thisSD = SGsd( "SG", "SG a=1")  

longKey = thisDataName*":"*LossFunctionString*":"*string(L2reg)*":"thisSD.stepString*":"*"const"*":0"
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=20, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts,thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts,thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=100000, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=100001, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum, logarithmic = false)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=99, logarithmic = false)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=99, logarithmic = false)
alg(thisProblem(Task(() -> getRandom(numTrainingPoints, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction, myREfunction)
println(" gnum:     "*string(int(lrange(client, longKey*":gnum",0, -1))))
println(" origWant: "*string(int(lrange(client, longKey*":origWant",0, -1))))


println("TestRedisRuns successful!")
println()