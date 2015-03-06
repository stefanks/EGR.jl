using Base.Test
using EGR

createOracleOutputLevel = 1
numEquivalentPasses = 5
algOutputLevel = 0
maxOutputNum=20
constStepSize(k)=1 # ALL THIS MEANS IS A CONSTANT, SINCE WE ARE SEARCHING FOR THE BEST MULTIPLE HERE

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0

# myREfunction(problem, opts, sd, wantOutputs) = returnIfExists(client, problem, opts, sd, wantOutputs,0)
# myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = writeFunction(client, problem,  opts, sd,k, gnum, fromOutputsFunction)
myREfunction(problem, opts, sd, wantOutputs) = false
myWriteFunction(problem, sd, opts, k, gnum, fromOutputsFunction) = false


for thisOracle in Oracles
			
	(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem) = thisOracle
			
	println("numVars = $numVars")
	println("LossFunctionString = $LossFunctionString")
	
	myOutputOpts =  OutputOpts(myOutputter; maxOutputNum=maxOutputNum)
			
	maxG  = int(round(numEquivalentPasses*numTrainingPoints))
			
	myOpts(stepSizePower) = Opts(zeros(numVars); stepSizeFunction=constStepSize, stepSizePower=stepSizePower, maxG=maxG, outputLevel=algOutputLevel)
			
	#By now the oracles are created. 
	# From now on only concerned with the algorithm
		
	println("If s(k) = 0 and then numTrainingPoints, u(k) = numTrainingPoints, then 0 , gamma is natural, then egrs is equivalent to gd!!!")
		
	stepSize(k)=1.0
	

	getFullGradient(W) = gradientOracle(W)
	# Problem(L2reg, datasetHT["name"], LossFunctionString, getFullGradient, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient)))
	#  myOpts(0)
	#  GDsd( "GD")
	#  myOutputOpts
	#   myWriteFunction
	#    myREfunction
			
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromGD) = alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0),GDsd( "GD") , myOutputOpts, myWriteFunction, myREfunction)
	
		
	s(k,I) = sLikeGd(k,numTrainingPoints)
	u(k,I) =  uLikeGd(k,numTrainingPoints)
	beta(k) =1
	(outString, results_k, results_gnum,results_fromOutputsFunction,xFromEGRgd) = alg(thisProblem(Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))), myOpts(0), EGRsd(s,u,beta, numVars, true, csDataType, "EGR.GDlike"), myOutputOpts, myWriteFunction, myREfunction)
		
		
	relError = norm(xFromEGRgd-xFromGD)/norm(xFromGD)
		
	println("relError between EGR and GD = $relError")
	if relError>1e-13
		error("GD and EGR do not coincide")
	end
end



