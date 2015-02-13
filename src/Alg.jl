using StatsBase

immutable type OutputOpts
	logarithmic::Bool
	maxOutputNum::Int64
	average::Bool
	outputLevel::Int64
	outputsFunction::Function
	function OutputOpts(outputsFunction::Function; logarithmic::Bool = true, maxOutputNum::Int64 = 10, average::Bool=false, outputLevel::Int64=1)
		if maxOutputNum>99
			error("maxOutputNum too big")
		elseif maxOutputNum<1
			error("maxOutputNum too small")
		end
		outputLevel>2 && println("outputLevel is $outputLevel") 
		new(logarithmic, maxOutputNum, average, outputLevel,outputsFunction)
	end
end

immutable type Opts
	stepSize::Function
	init::Vector{Float64}
	maxG::Int64
	function Opts(init::Vector{Float64}, stepSize::Function; maxG::Int64=typemax(Int64)-35329)
		new(stepSize, init, maxG)
	end
end

function alg(opts::Opts, sp::StepParams, dh::DataHold, oo::OutputOpts, computeStep::Function)
	
	oo.outputLevel>0 && println("Starting alg")
	
	if oo.logarithmic == 1
		expIndices=unique(int(round(logspace(0,log10(opts.maxG+1),oo.maxOutputNum))))-1;
	else
		expIndices=unique(int(round(linspace(0,opts.maxG,oo.maxOutputNum))));
	end
	
	maxCounter = min(opts.maxG, expIndices[end]);
	
	results_k = Int64[]
	results_fromOutputsFunction = (String,Array{Float64,1})[]
	results_x = Array{Float64,1}[]

	x=opts.init
	kOutputs=1
	k=0
	gnum=0
	xSum=copy(x)
	
	oo.outputLevel>0 && println("        k    gnum       f         pcc      f-train")
	
	while true
		
		if gnum>= expIndices[kOutputs]
			if oo.average == 1
				xToTest =xSum/(k+1);
			else
				xToTest =x;
			end
			fromOutputsFunction = oo.outputsFunction(x)
			if oo.outputLevel>1 
				@printf("%2.i %7.i %7.i ", kOutputs, k, gnum)
				println(fromOutputsFunction[1])
			end
			push!(results_k,k)
			push!(results_fromOutputsFunction,fromOutputsFunction)
			push!(results_x,x)
			kOutputs += 1
		end
		
		gnum>=opts.maxG && break
		
	    (g, gnum) = computeStep(x, k, gnum, sp, dh);
		
		
		#  PUT IN ADAGRAD !!!
		x-=opts.stepSize(k)*g

		xSum = xSum+x;
		
		k+=1
		
	end
	
	if oo.outputLevel>0
		println("Finished alg")
		oo.outputLevel<=1 && println("Final Result:"*results_fromOutputsFunction[end][1])
	end
	(results_k, results_fromOutputsFunction, results_x )
end