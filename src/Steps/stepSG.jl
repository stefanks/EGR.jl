type SGsd <: StepData
	getStep::Function
	stepString::String
	shortString::String
	function SGsd(stepString::String, shortString::String)
		new(computeSGStep,stepString, shortString)
	end
	function SGsd()
		new(computeSGStep,"SG", "SG")
	end
end

function computeSGStep(x, k, gnum, sd::SGsd, problem::Problem; outputLevel =0)

	func = consume(problem.getNextSampleFunction)

	(f, g) = func(x)

	gnum += 1

	(g, gnum)

end
