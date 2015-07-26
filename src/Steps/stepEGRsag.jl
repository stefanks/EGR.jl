type EGRsagsd <: StepData
	A
	functions
	y
	I
	s::Function
	u::Function
	beta::Function
	getStep::Function
	stepString::String
	function EGRsagsd(s::Function, u::Function, beta::Function, numVars::Int64,dt::DataType, stepString::String)
		new(zeros(numVars),Function[], dt[],0, s, u, beta, EGRsagcomputation, stepString)
	end
end
#
# function onlyAdd(u::Function, numVars::Int64,dt::DataType, stepString::String, stepString::String)
# 	EGRsagsd(()->0, u, ()->0, numVars,dt, stepString, stepString)
# end
#
# function onlyUpdate(s::Function, beta::Function, numVars::Int64,dt::DataType, stepString::String, stepString::String)
# 	EGRsagsd(s,()->0, beta, numVars,dt, stepString, stepString)
# end

function EGRsaglinBeta1(c::Float64,numVars::Int64,ntp::Int64,  dt::DataType, stepString::String)
	EGRsagsd()
end

function EGRsagquadBeta1(c::Float64,numVars::Int64,ntp::Int64,  dt::DataType, stepString::String)
	EGRsagsd()
end


function EGRsagexpBeta1(c::Float64, r::Float64, numVars::Int64, ntp::Int64, dt::DataType)
	
	
	s =  (k,I)-> int(floor(k==0 ? 0 : c*(r/(r-1))^(k-1)))
	u = (k,I)-> int(floor(k==0 ? c*(r-1) : c*(r/(r-1))^(k-1))) 
	beta = (k)->0
	
	stepString  = "EGRsagexp"*".c="*string(c)*".r="*string(r)
	
	EGRsagsd(s, u , beta,  numVars,  dt,	stepString)
end

function EGRsagcomputation(x, k, gnum, sd::EGRsagsd, problem::Problem; outputLevel = 0)

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
	g = (sd.A- B + sumy )/(sd.I+sd.u(k,sd.I))
	sd.I = sd.I + sd.u(k,sd.I)
	sd.A=sd.A-B+sumy
	(g, gnum)
end
