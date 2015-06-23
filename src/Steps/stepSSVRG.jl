type SSVRGsd <: StepData

	t
	mtilde
	wtilde
	phat
	
	k::Function
	m::Int64
	getStep::Function
	stepString::String
	shortString::String
	function SSVRGsd(k::Function, m::Int64,  numVars::Int64, stepString::String, shortString::String)
		new(0,0,zeros(numVars), zeros(numVars),k,m, SSVRGComputation, stepString, shortString)
	end
end

function SSVRG(k::Function, m::Int64,  numVars::Int64)
	stepString = "ssvrg m = $m"
	shortString = "ssvrg m = $m"
	SSVRGsd(k, m,numVars, stepString, shortString)
end


function SSVRGfromEGR(myEGRsd::EGRsd,  numVars::Int64)
	
	
	# k = 
	# m = 
	stepString = "ssvrgFromEGR $(EGRsd.stepString)"
	shortString = "ssvrgFromEGR $(EGRsd.shortString)"
	SSVRGsd(k, m,numVars, stepString, shortString)
end

function SSVRGComputation(x, k, gnum, sd::SSVRGsd, problem::Problem; outputLevel = 0)
	outputLevel>0 && println("starting step computation")
	if sd.t ==  sd.mtilde
		outputLevel>0 && println("in outer cycle, recomputing mtilde, wtilde, phat")
		phatsum=zeros(x)
		for i = 1:sd.k(k)
			(f,sampleG) = ((consume(problem.getNextSampleFunction)))(x)
			outputLevel>0 && println("sampleG = $(sampleG)")
			phatsum += sampleG
		end
		gnum+=sd.k(k)
		sd.phat = phatsum/sd.k(k)
		sd.mtilde = rand(1:sd.m)
		sd.wtilde = copy(x)
		outputLevel>0 && println("sd.phat = $(sd.phat)")
		outputLevel>0 && println("sd.mtilde = $(sd.mtilde)")
		outputLevel>0 && println("sd.wtilde = $(sd.wtilde)")
		sd.t=0
	end
	kay = (consume(problem.getNextSampleFunction))
	(f,sampleG) = kay(x)
	(ft,sampleGt) = kay(sd.wtilde)
	gnum+=2
	g=sampleG-sampleGt+sd.phat
	sd.t+=1
	outputLevel>0 && println("finished step computation")
	(g, gnum)
end
