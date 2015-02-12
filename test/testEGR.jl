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

k=0

(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient) = createOracles(features,labels,numFeatures,numDatapoints,Set([1.0]); L2reg=false,outputLevel=0)
	
getNextSampleFunction() = getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	
stepSize(k)=0.001
s(k,I)=min(k,I)
u(k,I)= min(k+1, numTrainingPoints - I)
beta = 1
egr(
numTrainingPoints,
numVars,
stepSize,
outputsFunction,
s,
u,
beta,
getNextSampleFunction,
OutputOpts();
maxG=1000000)