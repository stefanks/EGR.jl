type Universalsd <: StepData
	A # Current sum of gradients. Start with a zeros sparse array
	f # Current array of gradient functions. Start with zero. 
	y # Current array of sparse gradients. Initialize empty. 
	I # Current number of total indices. 
	
	s::Function
	u::Function
	beta::Function
	getStep::Function
	stepString::String
	function Universalsd(s::Function, u::Function, beta::Function, numVars::Int64,  stepString::String)
		new(spzeros(numVars,1),Function[], SparseMatrixCSC[], 0, s, u, beta, Universalcomputation, stepString)
	end
end

function onlyAdd(u::Function, numVars::Int64, stepString::String)
	Universalsd(()->0, u, ()->0, numVars, stepString, stepString)
end

function onlyUpdate(s::Function, beta::Function, numVars::Int64, stepString::String)
	error("Need to add a k=0 initial build up!")
	Universalsd(s,()->0, beta, numVars, stepString, stepString)
end

function UniversallinBeta1(c::Float64,numVars::Int64,ntp::Int64,   stepString::String)
	Universalsd()
end

function UniversalquadBeta1(c::Float64,numVars::Int64,ntp::Int64,   stepString::String)
	Universalsd()
end


function UniversalexpBeta1(c::Float64, r::Float64, numVars::Int64, ntp::Int64, dt::DataType)
	
	
	s =  (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) 
	beta = (k)->0
	
	stepString  = "Universalexp"*".c="*string(c)*".r="*string(r)
	
	
	Universalsd(s, u , beta,  numVars,  dt,	stepString)
end



function Universalcomputation(x, k, gnum, sd::Universalsd, problem::Problem; outputLevel = 0)

	U = (sd.I+1):(sd.I+sd.u(k,sd.I))

	outputLevel > 0  && println("sd.I=$(sd.I) sd.u(k,sd.I)=$(sd.u(k,sd.I)) sd.s(k,sd.I)=$(sd.s(k,sd.I))")
	
	for i in U
		try
			push!(sd.f,consume(problem.getNextSampleFunction))
		catch
			error("Not producing anymore! Probably out of datapoints.")
		end
	end

	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false)

	B=zeros(size(x))

	for i in S
		B +=sd.y[i]
	end

	sumy=zeros(size(x))

	for i in [U]
		(f,sampleG) = (sd.f[i])(x)
		push!(sd.y,sampleG)
		sumy += sampleG
	end

	for i in [S]
		(f,sampleG) = (sd.f[i])(x)
		sd.y[i]=sampleG
		sumy += sampleG
	end

	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)
	g = ((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A): 0) - sd.beta(k)*B + sumy )/(sd.s(k,sd.I)+sd.u(k,sd.I))
	sd.I = sd.I + sd.u(k,sd.I)
	sd.A=sd.A-B+sumy
	(g, gnum)
end
