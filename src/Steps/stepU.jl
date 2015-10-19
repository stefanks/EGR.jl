type USD <: StepData
	
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
	stepString::AbstractString
	chunkSize::Int64
	numVars::Int64
	sagFsagaT::Bool
	
	function USD(s::Function, u::Function, beta::Function, numVars::Int64, stepString::AbstractString, chunkSize::Int64,sagFsagaT::Bool)
		new(spzeros(numVars,1),Function[], SparseMatrixCSC[], 0, s, u, beta, uComputation, stepString, chunkSize, numVars, sagFsagaT)
	end
end

function onlyAddBeta1(u::Function, uString::AbstractString, numVars::Int64, chunkSize::Int64,sagFsagaT::Bool)
	
	s = (k,I)-> 0
	beta = (k)->1
	
	stepString  = "uAb1."*uString*".cs="*string(chunkSize)*"."*string(sagFsagaT)
	
	USD(s, u , beta, numVars, stepString, chunkSize,sagFsagaT)

end

function onlyUpdateBeta1(s::Function, sString::AbstractString, numVars::Int64, ntp::Int64, chunkSize::Int64,sagFsagaT::Bool)
	
	u = (k,I)-> round(Int,floor(k==0 ? int(floor(ntp/chunkSize)) : 0))
	beta = (k)->1
	
	stepString  = "uUb1."*sString*".cs="*string(chunkSize)*"."*string(sagFsagaT)
	
	USD(s, u , beta, numVars, stepString, chunkSize,sagFsagaT)
end

function uLinBeta1(c::Float64,numVars::Int64, chunkSize::Int64,sagFsagaT::Bool)
	
	if c<1
		error("C must be >=1")
	end
	s = (k,I)-> round(Int,floor(k==0 ? 0 : c))
	u = (k,I)-> round(Int,c) 
	beta = (k)->1
	
	stepString  = "uLb1"*".c="*string(c)*".cs="*string(chunkSize)*"."*string(sagFsagaT)
	
	USD(s, u , beta, numVars, stepString, chunkSize,sagFsagaT)
end

function uQuadBeta1(c::Float64,numVars::Int64, chunkSize::Int64,sagFsagaT::Bool)
	
	s = (k,I)-> round(Int,ceil(k==0 ? 0 : c*k))
	u = (k,I)-> round(Int,ceil(c*(k+1)))
	beta = (k)->1
	
	stepString  = "uQb1"*".c="*string(c)*".cs="*string(chunkSize)*"."*string(sagFsagaT)
	
	USD(s, u , beta, numVars, stepString, chunkSize,sagFsagaT)
end


function uExpBeta1(r::Float64, numVars::Int64, chunkSize::Int64,sagFsagaT::Bool)
	
	c = 1.0 / (r-1)
	s = (k,I)-> round(Int,ceil(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> round(Int,ceil(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1)))
	beta = (k)->1
	
	stepString  = "uEb1"*".r="*string(r)*".cs="*string(chunkSize)*"."*string(sagFsagaT)
	
	USD(s, u , beta, numVars, stepString, chunkSize,sagFsagaT)
end

function uExp2Beta1(r::Float64, numVars::Int64, chunkSize::Int64,sagFsagaT::Bool)
	
	c = 1.0
	s = (k,I)-> round(Int,ceil(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> round(Int,ceil(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1)))
	beta = (k)->1
	
	stepString  = "uE2b1"*".r="*string(r)*".cs="*string(chunkSize)*"."*string(sagFsagaT)
	
	USD(s, u , beta, numVars, stepString, chunkSize,sagFsagaT)
end


function uComputation(x, k, gnum, sd::USD, problem::Problem; outputLevel = 0)

	outputLevel > 0 && println("Starting uComputation")
	
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))

	outputLevel > 0  && println("sd.I=$(sd.I) sd.u(k,sd.I)=$(sd.u(k,sd.I)) sd.s(k,sd.I)=$(sd.s(k,sd.I))")

	for i in U
		try
			for j in 1:sd.chunkSize
				push!(sd.f,consume(problem.getNextSampleFunction))
			end
		catch
			error("Not producing anymore! Probably out of datapoints.")
		end
	end

	# S is composed of chunk indices
	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false) 

	# B is the current sum of old gradients (for S)
	B = spzeros(sd.numVars,1)
	for i in collect(S)
		B +=sd.y[i]
	end

	# sumy is the new sum of gradients (for both U and S)
	sumy = spzeros(sd.numVars,1)	

	for i in collect(U)
		thisSum = spzeros(sd.numVars,1)	
		for j in (i-1)*sd.chunkSize+1:i*sd.chunkSize
			(f,sampleG) = (sd.f[j])(x)
			# MIGHT BE SLOW
			thisSum+=sparse(sampleG)
		end
		push!(sd.y,thisSum)
		sumy += thisSum
	end

	for i in collect(S)
		thisSum = spzeros(sd.numVars,1)	
		for j in (i-1)*sd.chunkSize+1:i*sd.chunkSize
			(f,sampleG) = (sd.f[j])(x)
			# MIGHT BE SLOW
			thisSum+=sparse(sampleG)
		end
		sd.y[i]=thisSum
		sumy += thisSum
	end

	gnum += sd.chunkSize * (sd.s(k,sd.I)+sd.u(k,sd.I))
	
	if sd.sagFsagaT == false
		g = (sd.A - B + sumy )/(sd.chunkSize*(sd.I+sd.u(k,sd.I)))
	else
		g = ((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A) - sd.beta(k)*B : 0) + sumy )/(sd.chunkSize*(sd.s(k,sd.I)+sd.u(k,sd.I)))
	end
	
	sd.I = sd.I + sd.u(k,sd.I)
	
	sd.A=sd.A-B+sumy
	
	(g, gnum)
end
