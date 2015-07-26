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

function DSSexp(c::Float64,r::Float64,ntp::Int64,stepString::String; outputLevel =0)
	DSSsd( (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))  >I ? I : int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1))),  (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) > ntp - I ? ntp-I : int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))), stepString)
end


function DSS(thisEGRsd::EGRsd)
	DSSsd(thisEGRsd.u,thisEGRsd.s, "DSS"*thisEGRsd.stepString)
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