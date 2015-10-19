type DSSsd <: StepData

	I # total points sampled
	s::Function
	u::Function
	getStep::Function
	stepString::AbstractString

	function DSSsd(s::Function, u::Function, stepString::AbstractString)
		new(0,s, u, DSScomputation, stepString)
	end
end

function DSS(thisUsd::USD)
	DSSsd(thisUsd.u,thisUsd.s, "DSS"*thisUsd.stepString)
end

function DSScomputation(x, k, gnum, sd::DSSsd, problem::Problem; outputLevel = 0)

	sumy=zeros(size(x))
	batchSize = sd.u(k,sd.I)+sd.s(k,sd.I)
	for i in 1:batchSize
		(f,sampleG) = (consume(problem.getNextSampleFunction))(x)
		sumy+=sampleG
	end

	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)

	sd.I = sd.I + sd.u(k,sd.I)
	
	(sumy/batchSize, gnum)
end