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
		
	function EGRsd(s::Function, u::Function, beta::Function, numVars::Int64, stepString)
		new(zeros(numVars),(Function,Function)[],Array{Float64,1}[],0, s, u, beta, naturalEGRS, stepString)
	end
end

type SGsd <: StepData
	getStep::Function
	stepString::String
	function SGsd(stepString)
		new(computeSGStep,stepString)
	end
end

type GDsd <: StepData
	getStep::Function
	stepString::String
	function GDsd(stepString)
		new(computeGDStep,stepString)
	end
end

function naturalEGRS(x, k, gnum, sd::EGRsd, problem::Problem);
		
	U = (sd.I+1):(sd.I+sd.u(k,sd.I))
	# println(U)
		
	for i in U
		# println(i)
		# println(typeof(sd.getNextSampleFunction))
		# println( consume(sd.getNextSampleFunction))
		# (func,cs) = consume(sd.getNextSampleFunction)
		# println(func([0.0,0])[2])
		# println(size(sd.functions))
	# 	println(sd.functions[1][1]([0.0,0])[2])
	# 	println(sd.functions[end][1]([0.0,0])[2])
	# 	show(sd.functions)
	# 	println()
		push!(sd.functions,consume(problem.getNextSampleFunction))
		# show(sd.functions)
	# 	println()
	# 	println(sd.functions[1][1]([0.0,0])[2])
	# 	println(sd.functions[end][1]([0.0,0])[2])
	end
	#
	# println("These should be different!!!")
	# println(sd.functions[1][1]([0.0,0])[2])
	# println(sd.functions[end][1]([0.0,0])[2])
	
	S = StatsBase.sample(1:sd.I,sd.s(k,sd.I);replace=false)
	# println(S)
		
	B=zeros(size(x))
		
	for i in S
		B +=sd.functions[i][2](sd.y[i])
	end
    # println("B/sd.s(k,sd.I) = $(B/sd.s(k,sd.I))")
		
	sumy=zeros(size(x))

	for i in [U]
		# println(i)
		(f,sampleG,cs) = (sd.functions[i][1])(x)
		# println("sampleG = $sampleG")
		# println(size(cs))
		push!(sd.y,cs)
		sumy += sampleG
	end

	for i in [S]
		# println(i)
		(f,sampleG,cs) = (sd.functions[i][1])(x)
		# println("sampleG = $sampleG")
		sd.y[i]=cs
		sumy += sampleG
	end
		
	gnum += sd.s(k,sd.I)+sd.u(k,sd.I)	
	
	# println("sumy = $sumy")
	#     println("sumy/sd.u(k,sd.I) = $(sumy/sd.u(k,sd.I))")
	# println("sumy/sd.s(k,sd.I) = $(sumy/sd.s(k,sd.I))")
	# println("sd.A = $(sd.A)")
	# println("$((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A): 0)- sd.beta(k)*B ) ")
		
	g = ((sd.s(k,sd.I) > 0  ? sd.s(k,sd.I)*((sd.beta(k)/sd.I)*sd.A): 0) - sd.beta(k)*B + sumy )/(sd.s(k,sd.I)+sd.u(k,sd.I))
		
	sd.I = sd.I + sd.u(k,sd.I)
		
	# println(size(sd.A))
	# println(size(B))
	# println(size(sumy))
	sd.A=sd.A-B+sumy
		
	(g, gnum)
end

function computeGDStep(x, k, gnum, sd::GDsd,problem::Problem)

	(f,g, margins)= problem.getFullGradient(x)
	
	gnum += problem.numTrainingPoints
	
	(g, gnum)
	
end

function computeSGStep(x, k, gnum, sd::SGsd, problem::Problem)

	# println(typeof(sp.getNextSampleFunction))
	(func,cs) = consume(problem.getNextSampleFunction)
	
	(f, g, cs) = func(x)
	
	gnum += 1
	
	(g, gnum)
	
end