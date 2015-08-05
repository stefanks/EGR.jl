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
(n,ntp,dt)->uQuadBeta1(1.0,n,1,false),
(n,ntp,dt)->uExpBeta1(1.0,2.0,n,1,false),
(n,ntp,dt)->SGsd( "SG")
]





myREfunction(problem, opts, sd, expIndices,n) = returnIfExists(client, problem, opts, sd, expIndices,n; outputLevel = 0)
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, origWant, fromOutputsFunction; outputLevel = 0)

for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
	maxG  = int(round(numEquivalentPasses*numTP))
	myOpts(stepSizePower) = Opts(zeros(numVars,1);  stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
	for sd in sds
	
		thisSD = sd(numVars,numTP,csDataType)
	
		println("  stepString = $(thisSD.stepString)")
				
		algForSearch(stepSizePower) =alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))), myOpts(stepSizePower),thisSD, myOutputOpts, myWriteFunction, myREfunction)

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