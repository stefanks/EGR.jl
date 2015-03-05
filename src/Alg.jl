using StatsBase

abstract StepData

immutable type Outputter
	outputsFunction::Function
	outputStringHeader::String
	numOutputsFromOutputsFunction::Int64	
end

immutable type ResultFromOO
	resultString::String
	resultLine::Vector{Float64}
end

immutable type OutputOpts
	logarithmic::Bool
	maxOutputNum::Int64
	average::Bool
	ooString::String
	outputter::Outputter
	function OutputOpts(outputter::Outputter; logarithmic::Bool = true, maxOutputNum::Int64 = 10, average::Bool=false, ooString::String="logarithmic = $logarithmic, maxOutputNum = $maxOutputNum, average = $average")
		maxOutputNum>99 && error("maxOutputNum too big")
		maxOutputNum<1 && error("maxOutputNum too small")
		new(logarithmic, maxOutputNum, average, ooString, outputter)
	end
end

immutable type Opts
	init::Union(Vector{Float64},Matrix{Float64})
	stepSizeFunction::Function
	stepSizePower::Int64
	maxG::Int64
	outputLevel::Int64
	optsString::String
	function Opts(init::Union(Vector{Float64},Matrix{Float64}); stepSizeFunction::Function=(k)->1/(k+1), stepSizePower::Int64=1, maxG::Int64=typemax(Int64)-35329, outputLevel::Int64=1, optsString::String="stepSizePower = $stepSizePower, maxG = $maxG")
		outputLevel>2 && println("outputLevel is $outputLevel") 
		(maxG>typemax(Int64)-35329 || maxG<0) && error("maxG is $maxG, and is out of range")
		stepSizeFunction(0) != 1 && error("stepSizeFunction(0) is $(stepSizeFunction(0)) instead of 1")
		new(init, stepSizeFunction, stepSizePower, maxG, outputLevel, optsString)
	end
end

immutable type Problem
	L2reg::Bool
	name::String
	lossFunctionString::String
	getFullGradient::Function # Optional!
	numTrainingPoints::Int64 # Optional!
	getNextSampleFunction::Task # Optional!
	function Problem(a,b,c,d,e,f)
		# println("In the Problem constructor!")
		new(a,b,c,d,e,f)
	end
end

function alg(problem::Problem, opts::Opts, sd::StepData, oo::OutputOpts, writeFunction::Function, returnResultIfExists::Function)
	
	opts.outputLevel>0 && println("Starting alg")
	
	if oo.logarithmic == true
		expIndices=unique(int(round(logspace(0,log10(opts.maxG+1),oo.maxOutputNum))))-1
	else
		expIndices=unique(int(round(linspace(0,opts.maxG,oo.maxOutputNum))))
	end
	
	trueOutputNum = length(expIndices)
	
	# println("trueOutputNum = $trueOutputNum")
	# println("expIndices = $expIndices")
	
	existingResult = returnResultIfExists(problem, opts, sd, trueOutputNum)

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
	
	opts.outputLevel>1 && println("        k    gnum"*oo.outputter.outputStringHeader)
	
	while true
		
		if gnum >= expIndices[kOutputs]
			if oo.average == 1
				xToTest = xSum/(k+1)
			else
				xToTest =x
			end
			# println("xToTest = $xToTest")
			# println("typeof(xToTest) = $(typeof(xToTest))")
			fromOutputsFunction::ResultFromOO = oo.outputter.outputsFunction(xToTest)
			if opts.outputLevel>1 
				@printf("%2.i %7.i %7.i ", kOutputs, k, gnum)
				println(fromOutputsFunction.resultString)
			end
			writeFunction(problem, sd, opts, k, gnum, fromOutputsFunction)
			if isnan(fromOutputsFunction.resultLine[end])
				 return ("NaN found", results_k, results_gnum,results_fromOutputsFunction,xToTest)
			 end
			push!(results_k,k)
			push!(results_gnum,gnum)
			results_fromOutputsFunction = [results_fromOutputsFunction ; fromOutputsFunction.resultLine']
			kOutputs += 1
		end
		
		gnum >= maxG && break
		
	    (g, gnum) = sd.getStep(x, k, gnum, sd, problem);
		
		opts.outputLevel>2 && println("norm(g) = $(norm(g))")
		
		opts.outputLevel>2 && println("norm(x) before step = $(norm(x))")

		# println("x = $x")
		# println("typeof(x) = $(typeof(x))")
		# println("g = $g")
		# println("typeof(g) = $(typeof(g))")
		#  PUT IN ADAGRAD !!!
		x-=(2.0^opts.stepSizePower)*opts.stepSizeFunction(k)*g

		# println("x = $x")
		# println("typeof(x) = $(typeof(x))")
		
		opts.outputLevel>2 && println("norm(x) after step = $(norm(x))")
		
		
		xSum = xSum+x;
		
		k+=1
		
	end
	
	if opts.outputLevel>0
		opts.outputLevel == 1 && println(opts.outputStringHeader)
		opts.outputLevel == 1 && println(results_fromOutputsFunction[end].resultString)
		println("Finished alg: $(sd.stepString)")
	end
	 
	## Write answer!
	("Finished nicely", results_k, results_gnum, results_fromOutputsFunction, xToTest)
end