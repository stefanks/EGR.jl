using Base.Test
using EGR

println("TestSAG")

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
	
    # println("When numChunks = 1, same as GD")
    #
    #
    #
    # println("When numChunks = 1, same as GD")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
	myOptss = Opts(zeros(numVars,1); stepSizePower=0, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)
	
	problem = thisProblem(Task(() -> getSequentialFinite(numTrainingPoints, gradientOracle)))
	y=csDataType[]
	for i in 1:numChunks
		println("Creating chunk $i")
		for j in (i-1)*int(floor(numTrainingPoints/numChunks))+1:i*int(floor(numTrainingPoints/numChunks))
			(f,sampleG) = (problem.getSampleFunctionAt(j))(myOptss.init)
			push!(y,sampleG)
		end
	end
	
	alg(problem,  myOptss, SAG(numVars, y, numTrainingPoints,numChunks,1), myOutputOpts, myWriteFunction, myREfunction)
end



println("TestSAG successful!")
println()