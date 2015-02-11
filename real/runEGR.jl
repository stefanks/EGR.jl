function getSequential(numTrainingPoints,mygradientOracle,restoreGradient)
	global k+=1
	if k<=numTrainingPoints
		k
	else
		error("Out of range")
	end
	g(x) = mygradientOracle(x,k)
	cs(cs) = restoreGradient(cs,k)
	(g,cs)
end

k=0

getNextSampleFunction() = getSequential(numTrainingPoints,mygradientOracle,restoreGradient)
	
stepSize(k)=1/sqrt(k+1)
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
maxG=1000)
