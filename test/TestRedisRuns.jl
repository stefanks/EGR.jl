using Base.Test
using EGR
using Redis


println("TestRedisRuns")

client = RedisConnection()

run(pipeline(`redis-cli keys "Test*"`, `xargs redis-cli del`))


createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 2
maxOutputNum=5


myREfunction(problem, opts, sd, expIndices,n) = returnIfExists(client, problem, opts, sd, expIndices,n; outputLevel = 0)
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, origWant, fromOutputsFunction; outputLevel = 0)

thisOracle=Oracles[1]
				
(gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) = thisOracle
		
maxG  = Int(round(numEquivalentPasses*numTP))

expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1

myOutputOpts =  OutputOpts(myOutputter,expIndices)
		
thisSD = SGsd( "SG.a=1")  

longKey = thisDataName*":"*LossFunctionString*":"*string(L2reg)*":"thisSD.stepString*":"*"const"*":0"
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=20, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts,thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=10, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts,thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=100000, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=100001, outputLevel=algOutputLevel)

alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))

myOpts= Opts(zeros(numVars,1); stepSizePower=0, maxG=30, outputLevel=algOutputLevel)
alg(thisProblem(Task(() -> getRandom(numTP, gradientOracle)))	, myOpts, thisSD, myOutputOpts, myWriteFunction)
println(" gnum:     "*string([parse(Int64,s) for s = lrange(client, longKey*":gnum",0, -1)]))
println(" origWant: "*string([parse(Int64,s) for s = lrange(client, longKey*":origWant",0, -1)]))


println("TestRedisRuns successful!")
println()