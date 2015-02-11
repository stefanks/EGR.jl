function getSequential(numDatapoints,gradientFunction,restoreGradient)
	global k+=1
	if k<=numDatapoints
		k
	else
		error("Out of range")
	end
	g(x) = gradientFunction(x,k)
	cs(cs) = restoreGradient(cs,k)
	(g,cs)
end

function EGRTest(numVars, numDatapoints,gradientFunction,restoreGradient,outputsFunction)


	getNextSampleFunction() = getSequential(numDatapoints,gradientFunction,restoreGradient)
	
	stepSize(k)=1/sqrt(k+1)
	s(k,I)=min(k,I)
	u(k,I)= min(k+1, numDatapoints - I)
	beta = 1
	egr(
		numDatapoints,
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

@test EGRTest(numVars, numDatapoints,gradientFunction,restoreGradient,outputsFunction)