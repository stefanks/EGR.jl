using Base.Test
using EGR

println("TestSAGA")

createOracleOutputLevel = 1
numEquivalentPasses = 10
algOutputLevel = 0
maxOutputNum=20
numChunks=5
stepOutputLevel = 0

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
	myOptss = Opts(zeros(numVars,1); stepSizePower=-10, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)

	for numChunks in [1,int(numTrainingPoints^(1/4)),int(numTrainingPoints^(2/4)),int(numTrainingPoints^(3/4)), numTrainingPoints]
	
		println("numChunks = $numChunks")
		problem = thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle)))
		y=csDataType[]
		for i in 1:numChunks
			# println("Working on chunk $i")
			for j in (i-1)*int(floor(numTrainingPoints/numChunks))+1:i*int(floor(numTrainingPoints/numChunks))
				(f,sampleG) = (problem.getSampleFunctionAt(j))(myOptss.init)
				push!(y,sampleG)
			end
		end
	
		alg(problem,  myOptss, SAGA(numVars, y, numTrainingPoints,numChunks), myOutputOpts, myWriteFunction, myREfunction)
	
	end
end



println("TestSAGA successful!")
println()