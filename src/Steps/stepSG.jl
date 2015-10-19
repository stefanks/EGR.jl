type SGsd <: StepData
	getStep::Function
	stepString::AbstractString
	function SGsd(stepString::AbstractString)
		new(computeSGStep,stepString)
	end
	function SGsd()
		new(computeSGStep,"SG")
	end
end

function computeSGStep(x, k, gnum, sd::SGsd, problem::Problem; outputLevel =0)

	func = consume(problem.getNextSampleFunction)

	(f, g) = func(x)

	gnum += 1

	(g, gnum)

end