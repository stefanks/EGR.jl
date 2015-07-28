type DSSsd <: StepData

	I
	s::Function
	u::Function
	getStep::Function
	stepString::String

	function DSSsd(s::Function, u::Function, stepString::String)
		new(0,s, u, DSScomputation, stepString)
	end
end

function DSS(thisUsd::USD)
	DSSsd(thisUsd.u,thisUsd.s, "DSS"*thisUsd.stepString)
end

function DSScomputation(x, k, gnum, sd::DSSsd, problem::Problem; outputLevel = 0)
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))
	# println(U)

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