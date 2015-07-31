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
	ooString::String
	outputter::Outputter
	expIndices
	function OutputOpts(outputter::Outputter,expIndices; average::Bool=false, ooString::String="average = $average")
		new(ooString, outputter,expIndices)
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
	numTrainingPoints::Int64 # Don't need for EGR
	getNextSampleFunction::Task
	getSampleFunctionAt::Function # Don't need for EGR
	function Problem(a,b,c,d,e,f)
		new(a,b,c,d,e,f)
	end
end

function alg(problem::Problem, opts::Opts, sd::StepData, oo::OutputOpts, writeFunction::Function)
	
	srand(1)
	
	opts.outputLevel>0 && println("Function to minimize: $(problem.name) with loss function $(problem.lossFunctionString), L2reg = $(problem.L2reg)")
	opts.outputLevel>0 && println("Step: $(sd.stepString) with stepSizePower = $(opts.stepSizePower)")
	
	opts.outputLevel>0 && println("Start confirmed")
	opts.outputLevel>0 && println("Opts: $(opts.optsString)")
	opts.outputLevel>0 && println("OutputOpts: $(oo.ooString)")
	
	maxG = min(opts.maxG, oo.expIndices[end]);
	
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
		
		if gnum >= oo.expIndices[kOutputs]
			xToTest =x
			fromOutputsFunction::ResultFromOO = oo.outputter.outputsFunction(xToTest)
			if opts.outputLevel>1 
				@printf("%2.i %8.i %8.i ", kOutputs, k, gnum)
				println(fromOutputsFunction.resultString)
			end
			writeFunction(problem, sd, opts, k, gnum, oo.expIndices[kOutputs], fromOutputsFunction)
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
		
		opts.outputLevel>2 && println("norm(g) before step = $(norm(g))")
		opts.outputLevel>2 && println("norm(x) before step = $(norm(x))")
		
		x-=(2.0^opts.stepSizePower)*g
		
		opts.outputLevel>2 && println("norm(x) after step = $(norm(x))")
	
		xSum += x;
		
		k+=1
		
	end
	
	exit()
	
	opts.outputLevel>0 && println("Finished alg: $(sd.stepString)")
	 
	## Write answer!
	("Finished nicely", results_k, results_gnum, results_fromOutputsFunction, xToTest)
end