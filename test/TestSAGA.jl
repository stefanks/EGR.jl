using Base.Test
using EGR

println("TestSAGA")

createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 0
maxOutputNum=20
numChunks=5

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
	myOptss = Opts(zeros(numVars,1); stepSizePower=0, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)
	
	problem = thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle)))
	y=csDataType[]
	for i in 1:numChunks
		println("Working on chunk $i")
		for j in (i-1)*int(numTrainingPoints/numChunks)+1:i*int(numTrainingPoints/numChunks)
			(f,sampleG) = (problem.getSampleFunctionAt(j))(myOptss.init)
			push!(y,sampleG)
		end
	end
	
	alg(problem,  myOptss, SAGA(numVars, y, numTrainingPoints,numChunks), myOutputOpts, myWriteFunction, myREfunction)
end



println("TestSAGA successful!")
println()