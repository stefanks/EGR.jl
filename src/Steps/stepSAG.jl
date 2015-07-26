type SAGsd <: StepData
	d
	y
	m::Int64
	numChunks::Int64
	batchSize::Int64
	getStep::Function
	stepString::String
	function SAGsd(numVars::Int64,y, stepString::String,numDp::Int64,numChunks::Int64, batchSize::Int64)
		d= sum(y)
		new(d, y, numDp, numChunks, batchSize, SAGComputation, stepString)
	end
end

function SAG(numVars::Int64, y, numDP::Int64,numChunks::Int64,batchSize::Int64)
	SAGsd(numVars,y, "SAG.$numChunks.$batchSize", numDP,numChunks,batchSize)
end


function SAGComputation(x, k, gnum, sd::SAGsd, problem::Problem; outputLevel =0)


	outputLevel >0 && println("  Starting SAG step computation")
	indices = sample(1:sd.numChunks,sd.batchSize;replace=false)
	outputLevel >1 && println("   indices = $indices")
	
	for i in indices

		outputLevel >1 && println("    Working on index $i")
		
		# step 1
		sd.d -= sd.y[i]
		sd.y[i] = zeros(sd.y[i] )
			   
		# step 2
		for j in (i-1)*int(floor(sd.m/sd.numChunks))+1:i*int(floor(sd.m/sd.numChunks))
			outputLevel >1 && println("     Working on sample point $j")
			(f,sampleG) = (problem.getSampleFunctionAt(j))(x)
			sd.y[i]+=sampleG
			gnum += 1
		end
	
		#step 3
		sd.d += sd.y[i]

	end

	outputLevel >0 && println("  Finished SAG step computation")
	
	(sd.d/sd.m, gnum)
end
