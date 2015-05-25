type GDsd <: StepData
	getStep::Function
	stepString::String
	shortString::String
	function GDsd(stepString::String, shortString::String)
		new(computeGDStep,stepString, shortString)
	end
end

function computeGDStep(x, k, gnum, sd::GDsd,problem::Problem)

	(f,g)= problem.getFullGradient(x)

	gnum += problem.numTrainingPoints

	(g, gnum)

end