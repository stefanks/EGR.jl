type UcbSD <: StepData
	
	A # Current sum of gradients. Start with a zeros sparse array
	f # Current array of gradient functions. Start with zero.
	  # Has all gradient function in it, no chunking here
 	y # Current array of sparse gradient sums. Initialize empty. 
	  # One gradient sum per chunk
	I # Current number of total chunks 
	
	s::Function # Number of chunks to resample
	u::Function # Number of new chunks to sample
	beta::Function
	getStep::Function
	stepString::String
	numVars::Int64
	sagFsagaT::Bool
	cc
	
	function UcbSD(s::Function, u::Function, beta::Function, numVars::Int64, stepString::String,sagFsagaT::Bool,cc)
		new(spzeros(numVars,1),Function[], Array(SparseMatrixCSC,int(maximum(cc))), 0, s, u, beta, ucbComputation, stepString, numVars, sagFsagaT,cc)
	end
end

function UcbonlyAddBeta1(u::Function, uString::String, numVars::Int64,sagFsagaT::Bool,cc)
	
	s = (k,I)-> 0
	beta = (k)->1
	
	stepString  = "ucbAb1."*uString*"."*string(sagFsagaT)
	
	UcbSD(s, u , beta, numVars, stepString,sagFsagaT,cc)

end

function UcbonlyUpdateBeta1(s::Function, sString::String, numVars::Int64, ntp::Int64,sagFsagaT::Bool,cc)
	
	u = (k,I)-> int(floor(k==0 ? ntp : 0))
	beta = (k)->1
	
	stepString  = "ucbUb1."*sString*"."*string(sagFsagaT)
	
	UcbSD(s, u , beta, numVars, stepString,sagFsagaT,cc)
end

function UcbuLinBeta1(c::Float64,numVars::Int64,sagFsagaT::Bool,cc)
	
	if c<1
		error("C must be >=1")
	end
	s = (k,I)-> int(floor(k==0 ? 0 : c))
	u = (k,I)-> int(c) 
	beta = (k)->1
	
	stepString  = "ucbLb1"*".c="*string(c)*"."*string(sagFsagaT)
	
	UcbSD(s, u , beta, numVars, stepString,sagFsagaT,cc)
end

function UcbuQuadBeta1(c::Float64,numVars::Int64,sagFsagaT::Bool,cc)
	
	s = (k,I)-> int(floor(k==0 ? 0 : c*k))
	u = (k,I)-> int(ceil(c*(k+1)))
	beta = (k)->1
	
	stepString  = "ucbQb1"*".c="*string(c)*"."*string(sagFsagaT)
	
	UcbSD(s, u , beta, numVars, stepString,sagFsagaT,cc)
end


function UcbuExpBeta1(c::Float64, r::Float64, numVars::Int64, chunkSize::Int64,sagFsagaT::Bool,cc)
	
	s = (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) 
	beta = (k)->1
	
	stepString  = "ucbEb1"*".c="*string(c)*".r="*string(r)*"."*string(sagFsagaT)
	
	UcbSD(s, u , beta, numVars, stepString,sagFsagaT,cc)
end



function ucbComputation(x, k, gnum, sd::UcbSD, problem::Problem; outputLevel = 0)

	outputLevel > 0 && println("Starting ucbComputation")
	
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))

	outputLevel > 0  && println("sd.I=$(sd.I) sd.u(k,sd.I)=$(sd.u(k,sd.I)) sd.s(k,sd.I)=$(sd.s(k,sd.I))")

	for i in U
		try
			push!(sd.f,consume(problem.getNextSampleFunction))
		catch
			error("Not producing anymore! Probably out of datapoints.")
		end
	end

	# S is composed of chunk indices
	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false) 

	# B is the current sum of old gradients (for S)
	B = spzeros(sd.numVars,1)
	for i in [S]
		B +=sd.y[sd.cc[i]]
	end

	# sumy is the new sum of gradients (for both U and S)
	sumy = spzeros(sd.numVars,1)	

	for i in [U]
		thisSum = spzeros(sd.numVars,1)
			(f,sampleG) = (sd.f[i])(x)
			# MIGHT BE SLOW
		thisSum+=sparse(sampleG)
		sd.y[sd.cc[i]]=thisSum
		sumy += thisSum
	end

	for i in [S]
		thisSum = spzeros(sd.numVars,1)	
			(f,sampleG) = (sd.f[i])(x)
			# MIGHT BE SLOW
			thisSum+=sparse(sampleG)
		sd.y[sd.cc[i]]=thisSum
		sumy += thisSum
	end

	gnum +=  (sd.s(k,sd.I)+sd.u(k,sd.I))
	
	if sd.sagFsagaT == false
		g = (sd.A - B + sumy )/((sd.I+sd.u(k,sd.I)))
	else
		g = ((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A) - sd.beta(k)*B : 0) + sumy )/((sd.s(k,sd.I)+sd.u(k,sd.I)))
	end
	
	sd.I = sd.I + sd.u(k,sd.I)
	
	sd.A=sd.A-B+sumy
	
	(g, gnum)
end
