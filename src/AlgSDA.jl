using StatsBase


function algSDA(problem::Problem, opts::Opts, oo::OutputOpts, writeFunction::Function)
	
	srand(1)
	
	opts.outputLevel>0 && println("Function to minimize: $(problem.name) with loss function $(problem.lossFunctionString), L2reg = $(problem.L2reg)")
	opts.outputLevel>0 && println("Step: SDA with stepSizePower = $(opts.stepSizePower)")
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

	xSum=copy(x)
	xToTest = zeros(size(x))
	
	opts.outputLevel>1 && println("        k     gnum"*oo.outputter.outputStringHeader)
	

	betahat=1
	
	while true
		
		if gnum >= oo.expIndices[kOutputs]
			xToTest = xSum/(k+1)
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

		func = consume(problem.getNextSampleFunction)
		(f, g) = func(x)
		
	    sumg += g
	    beta = (2.0^opts.stepSizePower) * betahat
	    x = -sumg/beta
	    if k>1
	    	betahat = betahat + 1/betahat
		end
		xSum += x;
		
		k+=1
		
	end
	
	exit()
	
	opts.outputLevel>0 && println("Finished alg: SDA")
	 
	## Write answer!
	("Finished nicely", results_k, results_gnum, results_fromOutputsFunction, xToTest)
end