type USDr <: StepData
	
	A # Current sum of gradients. Start with a zeros array
	f # Current array of gradient functions. Start with zero.
	  # Has all gradient function in it, no chunking here
 	y # Current array of compactly stored gradients
 	rf # Current array of restoring fucntions
	I # Current number of total chunks 
	
	s::Function # Number of chunks to resample
	u::Function # Number of new chunks to sample
	beta::Function
	getStep::Function
	stepString::String
	numVars::Int64
	sagFsagaT::Bool
	
	function USDr(s::Function, u::Function, beta::Function, numVars::Int64, stepString::String,sagFsagaT::Bool)
		new(zeros(numVars,1),Function[], Matrix{Float64}[], Function[], 0, s, u, beta, urComputation, stepString, numVars, sagFsagaT)
	end
end

function onlyrAddBeta1(u::Function, uString::String, numVars::Int64,sagFsagaT::Bool)
	
	s = (k,I)-> 0
	beta = (k)->1
	
	stepString  = "urAb1."*uString*"."*string(sagFsagaT)
	
	USDr(s, u , beta, numVars, stepString,sagFsagaT)

end

function onlyrUpdateBeta1(s::Function, sString::String, numVars::Int64, ntp::Int64,sagFsagaT::Bool)
	
	u = (k,I)-> int(floor(k==0 ? int(floor(ntp)) : 0))
	beta = (k)->1
	
	stepString  = "urUb1."*sString*"."*string(sagFsagaT)
	
	USDr(s, u , beta, numVars, stepString,sagFsagaT)
end

function urLinBeta1(c::Float64,numVars::Int64, sagFsagaT::Bool)
	
	if c<1
		error("C must be >=1")
	end
	s = (k,I)-> int(floor(k==0 ? 0 : c))
	u = (k,I)-> int(c) 
	beta = (k)->1
	
	stepString  = "urLb1"*".c="*string(c)*"."*string(sagFsagaT)
	
	USDr(s, u , beta, numVars, stepString, sagFsagaT)
end

function urQuadBeta1(c::Float64,numVars::Int64,sagFsagaT::Bool)
	
	s = (k,I)-> int(ceil(k==0 ? 0 : c*k))
	u = (k,I)-> int(ceil(c*(k+1)))
	beta = (k)->1
	
	stepString  = "urQb1"*".c="*string(c)*"."*string(sagFsagaT)
	
	USDr(s, u , beta, numVars, stepString,sagFsagaT)
end


function urExpBeta1(r::Float64, numVars::Int64,sagFsagaT::Bool)
	
	c = 1.0 / (r-1)
	s = (k,I)-> int(ceil(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(ceil(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1)))
	beta = (k)->1
	
	stepString  = "urEb1"*".r="*string(r)*"."*string(sagFsagaT)
	
	USDr(s, u , beta, numVars, stepString,sagFsagaT)
end

function urExpBeta0(r::Float64, numVars::Int64,sagFsagaT::Bool)
	
	c = 1.0 / (r-1)
	s = (k,I)-> int(ceil(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(ceil(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1)))
	beta = (k)->0
	
	stepString  = "urEb0"*".r="*string(r)*"."*string(sagFsagaT)
	
	USDr(s, u , beta, numVars, stepString,sagFsagaT)
end



function urComputation(x, k, gnum, sd::USDr, problem::Problem; outputLevel = 0)

	outputLevel > 0 && println("Starting urComputation")
	
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))

	outputLevel > 0  && println("sd.I=$(sd.I) sd.u(k,sd.I)=$(sd.u(k,sd.I)) sd.s(k,sd.I)=$(sd.s(k,sd.I))")

	for i in U
		try
			# println("before consume")
			# println(problem.getNextSampleFunction)
			kkkkkk=consume(problem.getNextSampleFunction)
			# println("after consume")
			push!(sd.f, kkkkkk[1])
			push!(sd.rf,kkkkkk[2])
		catch
			error("Not producing anymore! Probably out of datapoints.")
		end
	end

	# S is composed of sample indices
	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false) 

	# B is the current sum of old gradients (for S)
	B = zeros(sd.numVars,1)
	for i in [S]
		B += sd.rf[i](sd.y[i]) # RF is the restoring function
	end

	# sumy is the new sum of gradients (for both U and S)
	sumy = zeros(sd.numVars,1)	

	for i in [U]
		(f,sampleG,cs) = (sd.f[i])(x)
		push!(sd.y,cs)
		sumy += sampleG
	end

	for i in [S]
		(f,sampleG,cs) = (sd.f[i])(x)
		push!(sd.y,cs)
		sumy += sampleG
	end

	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)
	
	if sd.sagFsagaT == false
		g = (sd.A - B + sumy )/(sd.I+sd.u(k,sd.I))
	else
		g = ((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A) - sd.beta(k)*B : 0) + sumy )/(sd.s(k,sd.I)+sd.u(k,sd.I))
	end
	
	sd.I = sd.I + sd.u(k,sd.I)
	
	sd.A=sd.A-B+sumy
	
	(g, gnum)
end
