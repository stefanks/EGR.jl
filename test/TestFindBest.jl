using Base.Test
using EGR
using Redis

println("TestFindBest")

client = RedisConnection()

# run(`redis-cli keys "Test*"` |> `xargs redis-cli del`)
run(pipeline(`redis-cli keys "Test*"`, `xargs redis-cli del`))

createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1

sds = [
(n,ntp,dt)->uQuadBeta1(1.0,n,1,false),
(n,ntp,dt)->uExpBeta1(2.0,n,1,false),
(n,ntp,dt)->SGsd( "SG")
]




myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, origWant, fromOutputsFunction; outputLevel = 0)

for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	maxG  = Int(round(numEquivalentPasses*numTP))
	
	expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1
	
	myOutputOpts =  OutputOpts(myOutputter,expIndices)
	myOpts(stepSizePower) = Opts(zeros(numVars,1);  stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
	for sd in sds
	
		thisSD = sd(numVars,numTP,csDataType)
	
		println("  stepString = $(thisSD.stepString)")
				
		algForSearch(stepSizePower) =alg(thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))), myOpts(stepSizePower),thisSD, myOutputOpts, myWriteFunction)
		
		returnResultIfExists(stepSizePower) = returnIfExists(client,thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle))), myOpts(stepSizePower), thisSD,expIndices,myOutputOpts.outputter.numOutputsFromOutputsFunction)

		findBests = [((res)->getF(res,maxG),0.0,"getF"),((res)->getPCC(res,maxG),-1.0,"getPCC"), ((res)->getMCC(res,maxG),-1.0,"getMCC")]
				
		for findBest in findBests
			println("   findBest = $(findBest[3])")
			(bestPower, bestVal) = findBestStepsizeFactor(algForSearch,findBest...,returnResultIfExists;outputLevel = 0)
			
				
				
			println("   Best stepsize power = $bestPower, best value = $bestVal")
		end
	end
end


println("TestFindBest successful!")
println()