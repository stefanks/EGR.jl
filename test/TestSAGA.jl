using Base.Test
using EGR

println("TestSAGA")

createOracleOutputLevel = 1
numEquivalentPasses = 10
algOutputLevel = 0
maxOutputNum=20
numChunks=5
stepOutputLevel = 0

sLikeGd(k,numTP) = k==0 ? 0 : numTP
uLikeGd(k,numTP) = k==0 ? numTP : 0


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
			
	maxG  = Int(round(numEquivalentPasses*numTP))
	
	expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1
	
	myOutputOpts =  OutputOpts(myOutputter,expIndices)
	myOptss = Opts(zeros(numVars,1); stepSizePower=-10, maxG=maxG, outputLevel=algOutputLevel, stepOutputLevel=0)

	for numChunks in [1,round(Int,numTP^(1/4)),round(Int,numTP^(2/4)),round(Int,numTP^(3/4)), numTP]
	
		println("numChunks = $numChunks")
		problem = thisProblem(Task(() -> getSequentialFinite(numTP, gradientOracle)))
		y=csDataType[]
		for i in 1:numChunks
			# println("Working on chunk $i")
			for j in (i-1)*round(Int,floor(numTP/numChunks))+1:i*round(Int,floor(numTP/numChunks))
				(f,sampleG) = (problem.getSampleFunctionAt(j))(myOptss.init)
				push!(y,sampleG)
			end
		end
	
		alg(problem,  myOptss, SAGA(numVars, y, numTP,numChunks,1), myOutputOpts, myWriteFunction)
	
	end
end



println("TestSAGA successful!")
println()