type GDsd <: StepData
	getStep::Function
	stepString::String
	function GDsd(stepString::String)
		new(computeGDStep,stepString)
	end
end

function computeGDStep(x, k, gnum, sd::GDsd,problem::Problem; outputLevel =0)

	(f,g)= problem.getFullGradient(x)

	gnum += problem.numTrainingPoints

	(g, gnum)

end