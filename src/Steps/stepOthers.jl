type DSSsd <: StepData

	I
	s::Function
	u::Function
	getStep::Function
	stepString::String
	shortString::String

	function DSSsd(s::Function, u::Function, stepString::String, shortString::String)
		new(0,s, u, DSS, stepString, shortString)
	end
end

function DSSexp(c::Float64,r::Float64,ntp::Int64,stepString::String, shortString::String)
	DSSsd( (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))  >I ? I : int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1))),  (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) > ntp - I ? ntp-I : int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))), stepString, shortString)
end

type SGsd <: StepData
	getStep::Function
	stepString::String
	shortString::String
	function SGsd(stepString::String, shortString::String)
		new(computeSGStep,stepString, shortString)
	end
end

type GDsd <: StepData
	getStep::Function
	stepString::String
	shortString::String
	function GDsd(stepString::String, shortString::String)
		new(computeGDStep,stepString, shortString)
	end
end

function DSS(x, k, gnum, sd::DSSsd, problem::Problem);
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))
	# println(U)

	sumy=zeros(size(x))
	batchSize = sd.u(k,sd.I)+sd.s(k,sd.I)
	for i in 1:batchSize
		(f,sampleG,cs) = ((consume(problem.getNextSampleFunction))[1])(x)
		sumy+=sampleG
	end

	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)

	sd.I = sd.I + sd.u(k,sd.I)
	
	(sumy/batchSize, gnum)
end

function computeGDStep(x, k, gnum, sd::GDsd,problem::Problem)

	(f,g)= problem.getFullGradient(x)

	gnum += problem.numTrainingPoints

	(g, gnum)

end

function computeSGStep(x, k, gnum, sd::SGsd, problem::Problem)

	# println(typeof(sp.getNextSampleFunction))
	(func,cs) = consume(problem.getNextSampleFunction)

	(f, g, cs) = func(x)

	gnum += 1

	(g, gnum)

end
