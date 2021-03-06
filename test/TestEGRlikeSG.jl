using Base.Test
using EGR

println("TestEGRlikeSG")

createOracleOutputLevel = 1
numEquivalentPasses = 1
algOutputLevel = 0
maxOutputNum=20


myREfunction(problem, opts, sd, expIndices,n) = false
myWriteFunction(problem, sd, opts, k, gnum, origWant, fromOutputsFunction) = false


for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) in Oracles
	
	print(" $thisDataName $LossFunctionString L2reg = $L2reg")
		
			
	maxG  = Int(round(numEquivalentPasses*numTP))
	
	expIndices=unique(round(Int, logspace(0,log10(maxG+1),maxOutputNum)))-1
	
	myOutputOpts =  OutputOpts(myOutputter,expIndices)
			
			
	myOpts(stepSizePower) = Opts(zeros(numVars,1); stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
		
	s(k,I) = 0
	u(k,I) = 1
	beta(k) = 1
			
	a = Task(() -> getSequentialFinite(numTP, gradientOracle))
	b = Task(() -> getSequentialFinite(numTP, gradientOracle))
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGR) = alg(thisProblem(a)	, myOpts(0), USD(s,u,beta,numVars,  "EGR.SGlike.a=1",1,true), myOutputOpts, myWriteFunction)
	
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromSG)  = alg(thisProblem(b)	, myOpts(0), SGsd( "SG.a=1")                                               , myOutputOpts, myWriteFunction)
		
		
		
		
	relError = norm(xFromEGR-xFromSG)/norm(xFromSG)
		
	println(" relError between EGR and SG = $relError")
	if relError>1e-13
		error("SG and EGR do not coincide")
	end
			
end


println("TestEGRlikeSG successful!")
println()