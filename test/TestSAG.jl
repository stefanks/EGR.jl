using Base.Test
using EGR

println("TestSAG")

createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=20
numChunks=3

sLikeGd(k,numTP) = k==0 ? 0 : numTP
uLikeGd(k,numTP) = k==0 ? numTP : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	println(" numTP = $numTP")
			
	maxG  = Int(round(numEquivalentPasses*numTP))
	
	expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1
	
	myOutputOpts =  OutputOpts(myOutputter,expIndices)
	myOptss = Opts(zeros(numVars,1); stepSizePower=0, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)
	
	problem = thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle)))
	y=csDataType[]
	for i in 1:numChunks
		println("  Creating chunk $i")
		for j in (i-1)*round(Int,floor(numTP/numChunks))+1:i*round(Int,floor(numTP/numChunks))
			(f,sampleG) = (problem.getSampleFunctionAt(j))(myOptss.init)
			push!(y,sampleG)
		end
	end
	
	alg(problem,  myOptss, SAG(numVars, copy(y), numTP,numChunks,1), myOutputOpts, myWriteFunction)
	
	alg(problem,  myOptss, SAG(numVars, copy(y), numTP,numChunks,2), myOutputOpts, myWriteFunction)
	
end



println("TestSAG successful!")
println()