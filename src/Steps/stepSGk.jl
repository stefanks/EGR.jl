type SGksd <: StepData
	getStep::Function
	stepString::String
	function SGksd(stepString::String)
		new(computeSGkStep,stepString)
	end
	function SGksd()
		new(computeSGkStep,"SGk")
	end
end

function computeSGkStep(x, k, gnum, sd::SGksd, problem::Problem; outputLevel =0)

	func = consume(problem.getNextSampleFunction)

	(f, g) = func(x)

	gnum += 1

	(g/(k+1), gnum)

end
