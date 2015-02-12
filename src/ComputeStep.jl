abstract StepParams

abstract DataHold

immutable EGRStepParams <: StepParams
	s
	u
	beta
	getNextSampleFunction
end

immutable SGStepParams <: StepParams
	getNextSampleFunction
end

immutable GDStepParams <: StepParams
	getFullGradient
	numTrainingPoints
end


type EGRdata_hold <: DataHold
	A
	functions
	restoreFunctions
	y
	I
	function EGRdata_hold(numVars)
		new(zeros(numVars),Function[],Function[],Array{Float64,1}[],0)
	end
end

type GDData_hold <: DataHold
end

type SGData_hold <: DataHold
end

function computeEGRStep(x, k, gnum, sp::StepParams, dh::DataHold);
		
	
	U = (dh.I+1):(dh.I+sp.u(k,dh.I))
		
	for i in U
		(a,b) =sp.getNextSampleFunction()
		push!(dh.functions,a)
		push!(dh.restoreFunctions,b)
	end
		
		
	S = StatsBase.sample(1:dh.I,sp.s(k,dh.I);replace=false)
		
	B=zeros(size(x))
		
	for i in S
		B +=dh.restoreFunctions[i](dh.y[i])
	end
		
	sumy=zeros(size(x))

	for i in [U ; S]
		(f,sampleG,cs) = dh.functions[i](x)
		push!(dh.y,cs)
		sumy += sampleG
	end
		
		
	gnum += sp.s(k,dh.I)+sp.u(k,dh.I)	
		
	g = (sp.s(k,dh.I) > 0  ? sp.s(k,dh.I)*(sp.beta/dh.I*dh.A): 0 - sp.beta*B + sumy )/(sp.s(k,dh.I)+sp.u(k,dh.I))
		
	dh.I = dh.I + sp.u(k,dh.I)
		
	dh.A=dh.A-B+sumy
		
	(g, gnum)
end

function computeGDStep(x, k, gnum, sp::StepParams, dh::DataHold)

	(f,g, margins)= sp.getFullGradient(x)
	
	gnum+=sp.numTrainingPoints
	
	(g, gnum)
	
end


function computeSGStep(x, k, gnum, sp::StepParams, dh::DataHold)

	(func,cs)= sp.getNextSampleFunction()
	
	(f, g, cs) = func(x)
	
	gnum+=1
	
	(g, gnum)
	
end