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

function EGRTest(gradientOracle,numTrainingPoints,numVars,outputsFunction,restoreGradient)

	getNextSampleFunction() = getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	
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
	true
end

k=0

include("Generate10dpProblem.jl")

@test EGRTest(Generate10dpProblem()...)