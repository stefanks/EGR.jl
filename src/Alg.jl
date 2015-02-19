using StatsBase

immutable type OutputOpts
	logarithmic::Bool
	maxOutputNum::Int64
	average::Bool
	outputLevel::Int64
	outputsFunction::Function
	outputStringHeader::String
	function OutputOpts(outputsFunction::Function,outputStringHeader::String; logarithmic::Bool = true, maxOutputNum::Int64 = 10, average::Bool=false, outputLevel::Int64=1)
		maxOutputNum>99 && error("maxOutputNum too big")
		maxOutputNum<1 && error("maxOutputNum too small")
		outputLevel>2 && println("outputLevel is $outputLevel") 
		new(logarithmic, maxOutputNum, average, outputLevel,outputsFunction,outputStringHeader)
	end
end

immutable type Opts
	stepSize::Function
	init::Vector{Float64}
	maxG::Int64
	function Opts(init::Vector{Float64}, stepSize::Function; maxG::Int64=typemax(Int64)-35329)
		(maxG>typemax(Int64)-35329 || maxG<0) && error("maxG is $maxG, and is out of range")
		typeof(stepSize(0)) != Float64 && error("typeof(stepSize(0)) = $(typeof(stepSize(0)))")
		new(stepSize, init, maxG)
	end
end

function alg(opts::Opts, sd::StepData, oo::OutputOpts, writeFunction::Function)
	
	oo.outputLevel>0 && println("Starting alg: $(sd.stepString)")
	
	# oo.outputLevel>0 && println("getting writeLoc")
	
	writeLoc = writeFunction(opts.stepSize(0)) 
	
	oo.outputLevel>0 && println("typeof(writeLoc) = $(typeof(writeLoc))")
	
	if ~isa(writeLoc, String)
		if typeof(writeLoc) != (String, Vector{Int64}, Vector{Int64},Vector{(String,Array{Float64,1})}, Vector{Array{Float64,1}})
			error("writeLoc type is wrong: $(typeof(writeLoc))")
		end
		# oo.outputLevel>0 && println("Returning!!")
		# oo.outputLevel>0 && println(writeLoc)
		return(writeLoc)
	end
	
	if oo.logarithmic == true
		expIndices=unique(int(round(logspace(0,log10(opts.maxG+1),oo.maxOutputNum))))-1;
	else
		expIndices=unique(int(round(linspace(0,opts.maxG,oo.maxOutputNum))));
	end
	
	maxCounter = min(opts.maxG, expIndices[end]);
	
	results_k = Int64[]
	results_gnum = Int64[]
	results_fromOutputsFunction = (String,Array{Float64,1})[]
	results_x = Array{Float64,1}[]

	x=opts.init
	kOutputs=1
	k=0
	gnum=0
	xSum=copy(x)
	
	# oo.outputLevel>0 && println("oo.outputLevel = $(oo.outputLevel)")
	
	oo.outputLevel>1 && println("        k    gnum"*oo.outputStringHeader)
	
	while true
		
		if gnum>= expIndices[kOutputs]
			if oo.average == 1
				xToTest =xSum/(k+1);
			else
				xToTest =x;
			end
			fromOutputsFunction = oo.outputsFunction(x)
			fromOutputsFunction == false && break
			if oo.outputLevel>1 
				@printf("%2.i %7.i %7.i ", kOutputs, k, gnum)
				println(fromOutputsFunction[1])
			end
			writeFunction(writeLoc, k, gnum, fromOutputsFunction, x)
			push!(results_k,k)
			push!(results_gnum,gnum)
			push!(results_fromOutputsFunction,fromOutputsFunction)
			push!(results_x,x)
			kOutputs += 1
		end
		
		gnum>=opts.maxG && break
		
	    (g, gnum) = sd.getStep(x, k, gnum, sd);
		
		# println("g = $g")
		
		# println(norm(x))
		
		#  PUT IN ADAGRAD !!!
		x-=opts.stepSize(k)*g
		
		xSum = xSum+x;
		
		k+=1
		
	end
	
	if oo.outputLevel>0
		oo.outputLevel == 1 && println(oo.outputStringHeader)
		oo.outputLevel == 1 && println(results_fromOutputsFunction[end][1])
		println("Finished alg: $(sd.stepString)")
	end
	
	## Write answer!
	("Finished nicely", results_k, results_gnum,results_fromOutputsFunction, results_x)
end