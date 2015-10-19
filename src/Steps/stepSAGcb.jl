type SAGcbsd <: StepData
	d
	y
	numClasses::Int64
	c::Vector{Int64}
	batchSize::Int64
	getStep::Function
	stepString::AbstractString
	m
	function SAGcbsd(numVars::Int64,y, stepString::AbstractString, batchSize::Int64,c,m)
		d= sum(y)
		new(d, y, size(y)[1], c,batchSize, SAGcbComputation, stepString,m)
	end
end

function SAGcb(numVars::Int64, y, batchSize::Int64,c::Vector{Int64},m)
	SAGcbsd(numVars,y, "SAGcb.$batchSize",  batchSize,c,m)
end


function SAGcbComputation(x, k, gnum, sd::SAGcbsd, problem::Problem; outputLevel =0)


	outputLevel >0 && println("  Starting SAG CB step computation")
	indices = sample(1:sd.m,sd.batchSize;replace=false)
	outputLevel >1 && println("   indices = $indices")
	
	for i in indices

		outputLevel >1 && println("    Working on index $i")
		
		# step 1
		sd.d -= sd.y[sd.c[i]]
			   
		(f,sampleG) = (problem.getSampleFunctionAt(i))(x)
		sd.y[sd.c[i]]=sampleG
		gnum += 1
	
		#step 3
		sd.d += sd.y[sd.c[i]]

	end

	outputLevel >0 && println("  Finished SAG CB step computation")
	
	(sd.d/sd.numClasses, gnum)
end
