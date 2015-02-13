abstract StepData

type EGRsd <: StepData
	A
	functions
	restoreFunctions
	y
	I

	s::Function
	u::Function
	beta::Function
	getNextSampleFunction::Task
	getStep::Function
		
	function EGRsd(s::Function, u::Function, beta::Function, getNextSampleFunction::Task, numVars::Int64)
		new(zeros(numVars),Function[],Function[],Array{Float64,1}[],0, s, u, beta, getNextSampleFunction,naturalEGRS)
	end
end

type SGsd <: StepData
	getNextSampleFunction :: Task
	getStep::Function
	function SGsd(getNextSampleFunction)
		new(getNextSampleFunction, computeSGStep)
	end
end

type GDsd <: StepData
	getFullGradient :: Function
	numTrainingPoints :: Int64
	getStep::Function
	function GDsd(getFullGradient,numTrainingPoints)
		new(getFullGradient,numTrainingPoints, computeGDStep)
	end
end

function naturalEGRS(x, k, gnum, sd::EGRsd);
		
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))
		
	for i in U
		# println(typeof(sd.getNextSampleFunction))
		# println( consume(sd.getNextSampleFunction))
		(func,cs) = consume(sd.getNextSampleFunction)
		push!(sd.functions,func)
		push!(sd.restoreFunctions,cs)
	end
		
	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false)
		
	B=zeros(size(x))
		
	for i in S
		B +=sd.restoreFunctions[i](sd.y[i])
	end
		
	sumy=zeros(size(x))

	for i in [U ; S]
		(f,sampleG,cs) = sd.functions[i](x)
		push!(sd.y,cs)
		sumy += sampleG
	end
		
		
	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)	
		
	g = (sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*(sd.beta(k)/sd.I*sd.A): 0 - sd.beta(k)*B + sumy )/(sd.s(k,sd.I)+sd.u(k,sd.I))
		
	sd.I = sd.I + sd.u(k,sd.I)
		
	sd.A=sd.A-B+sumy
		
	(g, gnum)
end

function computeGDStep(x, k, gnum, sd::GDsd)

	(f,g, margins)= sd.getFullGradient(x)
	
	gnum += sd.numTrainingPoints
	
	(g, gnum)
	
end

function computeSGStep(x, k, gnum, sd::SGsd)

	# println(typeof(sp.getNextSampleFunction))
	(func,cs) = consume(sd.getNextSampleFunction)
	
	(f, g, cs) = func(x)
	
	gnum += 1
	
	(g, gnum)
	
end