type EGRsd <: StepData
	A
	functions
	y
	I
	s::Function
	u::Function
	beta::Function
	getStep::Function
	stepString::String
	shortString::String
	function EGRsd(s::Function, u::Function, beta::Function, numVars::Int64,dt::DataType, stepString::String, shortString::String)
		new(zeros(numVars),Function[], dt[],0, s, u, beta, EGRcomputation, stepString, shortString)
	end
end

function onlyAdd(u::Function, numVars::Int64,dt::DataType, stepString::String, shortString::String)
	EGRsd(()->0, u, ()->0, numVars,dt, stepString, shortString)
end

function onlyUpdate(s::Function, beta::Function, numVars::Int64,dt::DataType, stepString::String, shortString::String)
	EGRsd(s,()->0, beta, numVars,dt, stepString, shortString)
end

function EGRlinBeta1(c::Float64,numVars::Int64,ntp::Int64,  dt::DataType, stepString::String, shortString::String)
	EGRsd()
end

function EGRquadBeta1(c::Float64,numVars::Int64,ntp::Int64,  dt::DataType, stepString::String, shortString::String)
	EGRsd()
end


function EGRexpBeta1(c::Float64, r::Float64, numVars::Int64, ntp::Int64, dt::DataType)
	
	
	s =  (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) 
	beta = (k)->0
	
	stepString  = "EGRexp"*".c="*string(c)*".r="*string(r)
	
	shortString = "EGRexp"*" c="*string(c)*" r="*string(r)
	
	EGRsd(s, u , beta,  numVars,  dt,	stepString, shortString)
end


function EGRexpBeta2(numVars::Int64, ntp::Int64, dt::DataType) # LEGACY!
	
	c=1
	r=ntp/400
	s =  (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) 
	beta = (k)->0
		#
	# stepString  = "EGRexpNatural"
	#
	# shortString = "EGRexpNatural"
	stepString  = "EGRexp"*".c="*string(c)*".r="*string(r)
	
	shortString = "EGRexp"*" c="*string(c)*" r="*string(r)
	
	EGRsd(s, u , beta,  numVars,  dt,	stepString, shortString)
end


# K is the total number of planned iterations
function EGRexpNatural(numVars::Int64, K::Int64, dt::DataType) 
	
	c=1
	r=K/400
	s =  (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) 
	beta = (k)->0
	
	stepString  = "EGRexpNatural"

	shortString = "EGRexpNatural"
	
	EGRsd(s, u , beta,  numVars,  dt,	stepString, shortString)
end

function EGRcomputation(x, k, gnum, sd::EGRsd, problem::Problem; outputLevel = 0)

	U = (sd.I+1):(sd.I+sd.u(k,sd.I))

	outputLevel > 0  && println("sd.I=$(sd.I) sd.u(k,sd.I)=$(sd.u(k,sd.I)) sd.s(k,sd.I)=$(sd.s(k,sd.I))")
	
	for i in U
		try
			push!(sd.functions,consume(problem.getNextSampleFunction))
		catch
			error("Not producing anymore!")
		end
	end

	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false)

	B=zeros(size(x))

	for i in S
		B +=sd.y[i]
	end

	sumy=zeros(size(x))

	for i in [U]
		(f,sampleG) = (sd.functions[i])(x)
		push!(sd.y,sampleG)
		sumy += sampleG
	end

	for i in [S]
		(f,sampleG) = (sd.functions[i])(x)
		sd.y[i]=sampleG
		sumy += sampleG
	end

	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)
	g = ((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A): 0) - sd.beta(k)*B + sumy )/(sd.s(k,sd.I)+sd.u(k,sd.I))
	sd.I = sd.I + sd.u(k,sd.I)
	sd.A=sd.A-B+sumy
	(g, gnum)
end
