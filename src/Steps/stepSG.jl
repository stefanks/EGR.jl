type SGsd <: StepData
	getStep::Function
	stepString::String
	function SGsd(stepString::String)
		new(computeSGStep,stepString)
	end
	function SGsd()
		new(computeSGStep,"SG")
	end
end

function computeSGStep(x, k, gnum, sd::SGsd, problem::Problem; outputLevel =0)

	func = consume(problem.getNextSampleFunction)

	(f, g) = func[1](x)

	gnum += 1

	(g, gnum)

end
