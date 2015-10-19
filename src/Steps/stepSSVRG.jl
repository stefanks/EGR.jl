type SSVRGsd <: StepData

	t
	mtilde
	wtilde
	phat
	
	k::Function
	m::Int64
	getStep::Function
	stepString::AbstractString
	function SSVRGsd(k::Function, m::Int64,  numVars::Int64, stepString::AbstractString)
		new(0,0,zeros(numVars), zeros(numVars),k,m, SSVRGComputation, stepString)
	end
end

function SSVRG(k::Function, m::Int64,  numVars::Int64)
	stepString = "ssvrg.m=$m"
	SSVRGsd(k, m,numVars, stepString)
end


function productionOfSandU(s,u)
	k=0
    while true
		produce(s(k,0)+u(k,0))
		k=k+1
	end
end

function kComputation(t::Task,gnum,mtilde)
	thisSum =0 
	for i=1:mtilde
		thisSum += consume(t)
	end
	max(thisSum-gnum,1)
end

function mytaskP(myarg)
	produce(myarg)
end

#
# function SSVRG(thisUsd::USD)
# 	thisProducer = @task  productionOfSandU(thisUsd.s,thisUsd.u)
# 	m = 100
#  	stepString = "ssvrgFromUm=100 $(thisEGRsd.stepString)"
# 	SSVRGsd((gnum,mtilde)->kComputation(thisProducer,gnum,mtilde), m,size(thisUsd.A)[1], stepString)
# end

function SSVRGComputation(x, k, gnum, sd::SSVRGsd, problem::Problem; outputLevel = 0)
	outputLevel>0 && println("starting step computation")
	if sd.t ==  sd.mtilde
		outputLevel>0 && println("in outer cycle, recomputing mtilde, wtilde, phat")
		phatsum=zeros(x)
		thisK = sd.k(gnum,sd.mtilde)
		for i = 1:thisK
			(f,sampleG) = (consume(problem.getNextSampleFunction))(x)
			outputLevel>0 && println("sampleG = $(sampleG)")
			phatsum += sampleG
		end
		gnum+=thisK
		sd.phat = phatsum/thisK
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
