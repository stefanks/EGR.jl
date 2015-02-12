using StatsBase

immutable type OutputOpts
	logarithmic::Bool
	outputNum::Int64
	average::Bool
	function OutputOpts(;logarithmic::Bool = true,outputNum::Int64 = 10, average::Bool=false)
		if outputNum>99
			error("outputNum too big")
		end
		new(logarithmic,outputNum, average)
	end
end

function egr(numTrainingPoints::Integer, numVars::Integer, stepSize::Function, outputsFunction::Function, sp::StepParams, dh::DataHold, outputOpts::OutputOpts, computeStep::Function; maxG=typemax(Int64)-35328, x=zeros(numVars))
	
	println("Starting egr-s")
	
	if outputOpts.logarithmic == 1
		expIndices=unique(int(round(logspace(0,log10(maxG),outputOpts.outputNum))));
	else
		expIndices=unique(int(round(linspace(0,maxG,outputOpts.outputNum))));
	end
	
	maxCounter = min(maxG, expIndices[end]);
	
	results_k = Int64[]
	results_f = Float64[]
	results_pcc = Float64[]
	results_x = Array{Float64,1}[]
	x=zeros(numVars)
	
	k=0
	gnum=0
	xSum=zeros(numVars)
	kOutputs=1
	
	println("        k    gnum       f         pcc      f-train")
	
	while true
		
	    (g, gnum) = computeStep(x, k, gnum, sp, dh);
		
		x-=stepSize(k)*g

		xSum = xSum+x;
		
		if gnum>= expIndices[kOutputs]
			if outputOpts.average == 1
				xToTest =xSum/(k+1);
			else
				xToTest =x;
			end
			((f, pcc),f_train) = outputsFunction(x)
            @printf("%2.i %7.i %7.i % .3e % .3e % .3e\n", kOutputs,k, gnum,f, pcc,f_train)
			push!(results_k,k)
			push!(results_f,f )
			push!(results_pcc,pcc )
			push!(results_x,x)
			kOutputs = kOutputs+1;
		end
		
		k+=1
		
			
		gnum>=maxG && break
		
		
	end
	
	
	println("Finished egr-s")
	(results_k ,results_f ,results_pcc ,results_x )
end