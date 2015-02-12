function getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	global k+=1
	if k<=numTrainingPoints
		k
	else
		error("Out of range")
	end
	g(x) = gradientOracle(x,k)
	cs(cs) = restoreGradient(cs,k)
	(g,cs)
end

(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient) = createOracles(features,labels,numFeatures,numDatapoints,Set([1.0]); L2reg=false,outputLevel=0)
	
k=0
	
stepSize(k)=0.001

getNextSampleFunction() = getSequential(numTrainingPoints,gradientOracle,restoreGradient)

egr(numTrainingPoints, numVars, stepSize, outputsFunction, SGStepParams(getNextSampleFunction), SGData_hold(), OutputOpts(),computeSGStep; maxG=10)

	
egr(numTrainingPoints, numVars, stepSize, outputsFunction, GDStepParams(gradientOracle, numTrainingPoints), GDData_hold(), OutputOpts(),computeGDStep; maxG=1000)
	
k=0

s(k,I)=min(k,I)
u(k,I)= min(k+1, numTrainingPoints - I)
beta = 1
egr(numTrainingPoints, numVars, stepSize, outputsFunction, EGRStepParams(s, u, beta, getNextSampleFunction), EGRdata_hold(numVars),OutputOpts(),computeEGRStep; maxG=1000)
