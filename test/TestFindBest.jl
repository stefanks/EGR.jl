using Base.Test
using EGR
using Redis

println("TestFindBest")

client = RedisConnection()

run(`redis-cli keys "Test*"` |> `xargs redis-cli del`);

createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1

sds = [
(n,ntp,dt)->EGRexpBeta1(1.0,2.0,n,ntp, dt),
(n,ntp,dt)->EGRsd((k,I)-> k >I ? I : k, (k,I)->k+1 > ntp - I ? ntp-I : k+1, (k)->1, n, dt, "alg4.s_k=k.u_k=k+1.b_k=1",  "alg4 lin, a=2^"),
(n,ntp,dt)->SGsd( "SG", "SG")
]

myREfunction(problem, opts, sd, expIndices,n) = returnIfExists(client, problem, opts, sd, expIndices,n; outputLevel = 0)
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, origWant, fromOutputsFunction; outputLevel = 0)

for (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
	myOpts(stepSizePower) = Opts(zeros(numVars,1);  stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
	for sd in sds
	
		thisSD = sd(numVars,numTrainingPoints,csDataType)
	
		println("  stepString = $(thisSD.stepString)")
				
		algForSearch(stepSizePower) =alg(thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle))), myOpts(stepSizePower),thisSD, myOutputOpts, myWriteFunction, myREfunction)

		findBests = [((res)->getF(res,maxG),0.0,"getF"),((res)->getPCC(res,maxG),-1.0,"getPCC"), ((res)->getMCC(res,maxG),-1.0,"getMCC")]
				
		for findBest in findBests
			println("   findBest = $(findBest[3])")
			(bestPower, bestVal) = findBestStepsizeFactor(algForSearch,findBest...;outputLevel = 0)
			println("   Best stepsize power = $bestPower, best value = $bestVal")
		end
	end
end


println("TestFindBest successful!")
println()