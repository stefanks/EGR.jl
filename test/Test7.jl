using Base.Test
using EGR
using Redis


client = RedisConnection();


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

findBests = [
"f", 
"pcc"
]

# myREfunction(problem, opts, sd, wantOutputs) = returnIfExists(client, problem, opts, sd, wantOutputs,0)
# myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, fromOutputsFunction)
myREfunction(problem, opts, sd, wantOutputs) = false
myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = false

for (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
			
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
	myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
			
	#By now the oracles are created. 
	# From now on only concerned with the algorithm

	for sd in sds
			
				
		algForSearch(stepSizePower) =alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(stepSizePower), sd(numVars,numTrainingPoints,csDataType), myOutputOpts, myWriteFunction, myREfunction)

		findBests = [((res)->getF(res,maxG),0.0),((res)->getPCC(res,maxG),-1.0), ((res)->getMCC(res,maxG),-1.0)]
				
		for findBest in findBests
			findBestStepsizeFactor(algForSearch,findBest...; outputLevel=1)
		end
				
	end
end


println("TestVerifyAndRestore successful!")
println()