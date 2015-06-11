using StatsBase

abstract StepData

immutable Outputter
	outputsFunction::Function
	outputStringHeader::String
	numOutputsFromOutputsFunction::Int64	
end

immutable ResultFromOO
	resultString::String
	resultLine::Vector{Float64}
end

immutable OutputOpts
	logarithmic::Bool
	maxOutputNum::Int64
	ooString::String
	outputter::Outputter
	function OutputOpts(outputter::Outputter; logarithmic::Bool = true, maxOutputNum::Int64 = 10, average::Bool=false, ooString::String="logarithmic = $logarithmic, maxOutputNum = $maxOutputNum, average = $average")
		maxOutputNum>99 && error("maxOutputNum too big")
		maxOutputNum<1 && error("maxOutputNum too small")
		new(logarithmic, maxOutputNum, ooString, outputter)
	end
end

immutable Opts
	init::Matrix{Float64}
	stepSizePower::Int64
	maxG::Int64
	outputLevel::Int64
	stepOutputLevel::Int64
	optsString::String
	function Opts(init::Matrix{Float64}; stepSizePower::Int64=1, maxG::Int64=typemax(Int64)-35329, outputLevel::Int64=1, optsString::String="stepSizePower = $stepSizePower, maxG = $maxG", stepOutputLevel::Int64=0)
		outputLevel>2 && println("outputLevel is $outputLevel") 
		(maxG>typemax(Int64)-35329 || maxG<0) && error("maxG is $maxG, and is out of range")
		new(init, stepSizePower, maxG, outputLevel, stepOutputLevel, optsString)
	end
end

immutable Problem
	L2reg::Bool
	name::String
	lossFunctionString::String
	getFullGradient::Function
	numTrainingPoints::Int64 # Don't need for EGR
	getNextSampleFunction::Task
	getSampleFunctionAt::Function # Don't need for EGR
	function Problem(a,b,c,d,e,f,g)
		new(a,b,c,d,e,f,g)
	end
end

function alg(problem::Problem, opts::Opts, sd::StepData, oo::OutputOpts, writeFunction::Function, returnResultIfExists::Function)
	
	srand(1)
	
	opts.outputLevel>0 && println("Function to minimize: $(problem.name) with loss function $(problem.lossFunctionString), L2reg = $(problem.L2reg)")
	opts.outputLevel>0 && println("Step: $(sd.stepString) with stepSizePower = $(opts.stepSizePower)")
	
	if oo.logarithmic == true
		expIndices=unique(round(Int, logspace(0,log10(opts.maxG+1),oo.maxOutputNum)))-1
	else
		expIndices=unique(round(Int, linspace(0,opts.maxG,oo.maxOutputNum)))
	end
	
	existingResult = returnResultIfExists(problem, opts, sd, expIndices, oo.outputter.numOutputsFromOutputsFunction)

	if existingResult != false
		if typeof(existingResult) != (ASCIIString,Vector{Int64},Vector{Int64},Array{Float64,2})
			error("existingResult type is wrong: $(typeof(existingResult))")
		end
		return existingResult
	end
	
	opts.outputLevel>0 && println("Start confirmed")
	opts.outputLevel>0 && println("Opts: $(opts.optsString)")
	opts.outputLevel>0 && println("OutputOpts: $(oo.ooString)")
	
	maxG = min(opts.maxG, expIndices[end]);
	
	results_k = Int64[]
	results_gnum = Int64[]
	results_fromOutputsFunction = zeros(0,oo.outputter.numOutputsFromOutputsFunction)

	kOutputs=1
	k=0
	gnum=0
	x=opts.init

	# println("x = $x")
	# println("typeof(x) = $(typeof(x))")
	xSum=copy(x)
	xToTest = zeros(size(x))
	
	# opts.outputLevel>0 && println("opts.outputLevel = $(opts.outputLevel)")
	
	opts.outputLevel>1 && println("        k     gnum"*oo.outputter.outputStringHeader)
	
	while true
		
		if gnum >= expIndices[kOutputs]
			xToTest =x
			fromOutputsFunction::ResultFromOO = oo.outputter.outputsFunction(xToTest)
			if opts.outputLevel>1 
				@printf("%2.i %8.i %8.i ", kOutputs, k, gnum)
				println(fromOutputsFunction.resultString)
			end
			writeFunction(problem, sd, opts, k, gnum, expIndices[kOutputs], fromOutputsFunction)
			if isnan(fromOutputsFunction.resultLine[end])
				return ("NaN found", results_k, results_gnum,results_fromOutputsFunction,xToTest)
			end
			push!(results_k,k)
			push!(results_gnum,gnum)
			results_fromOutputsFunction = [results_fromOutputsFunction ; fromOutputsFunction.resultLine']
			kOutputs += 1
		end
		
		gnum >= maxG && break
		
		(g, gnum) = sd.getStep(x, k, gnum, sd, problem; outputLevel = opts.stepOutputLevel)
		
		# println(typeof(g))
		
		opts.outputLevel>2 && println("norm(g) before step = $(norm(g))")
		opts.outputLevel>2 && println("norm(x) before step = $(norm(x))")
		
		#  PUT IN ADAGRAD !!!
		x-=(2.0^opts.stepSizePower)*g
		
		opts.outputLevel>2 && println("norm(x) after step = $(norm(x))")
	
		xSum = xSum+x;
		
		k+=1
		
	end
	
	opts.outputLevel>0 && println("Finished alg: $(sd.stepString)")
	 
	## Write answer!
	("Finished nicely", results_k, results_gnum, results_fromOutputsFunction, xToTest)
end