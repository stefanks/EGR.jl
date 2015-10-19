type SGsqrtsd <: StepData
	getStep::Function
	stepString::AbstractString
	function SGsqrtsd(stepString::AbstractString)
		new(computeSGsqrtStep,stepString)
	end
	function SGsqrtsd()
		new(computeSGsqrtStep,"SGsqrt")
	end
end

function computeSGsqrtStep(x, k, gnum, sd::SGsqrtsd, problem::Problem; outputLevel =0)

	func = consume(problem.getNextSampleFunction)

	(f, g) = func(x)

	gnum += 1

	(g/sqrt(k+1), gnum)

end
