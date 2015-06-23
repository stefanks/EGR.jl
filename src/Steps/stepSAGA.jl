type SAGAsd <: StepData
	d
	y
	m::Int64
	numChunks::Int64
	getStep::Function
	stepString::String
	shortString::String
	function SAGAsd(numVars::Int64,y, stepString::String, shortString::String,numDp::Int64,numChunks::Int64)
		new(zeros(numVars), y, numDp, numChunks, SAGAComputation, stepString, shortString)
	end
end

function SAGA(numVars::Int64, y, numDP::Int64,numChunks::Int64)
	SAGAsd(numVars,y, "SAGA", "SAGA", numDP,numChunks)
end


function SAGAComputation(x, k, gnum, sd::SAGsd, problem::Problem; outputLevel =0)

	i = rand(1:sd.numChunks)
	
	# step 1
	sd.d -= sd.y[i]
	sd.y[i] = zeros(sd.y[i] )
			   
	# step 2
	for j in (i-1)*int(floor(sd.m/sd.numChunks))+1:i*int(floor(sd.m/sd.numChunks))
		(f,sampleG) = (problem.getSampleFunctionAt(j))(x)
		sd.y[i]+=sampleG
		gnum += 1
	end
	
	#step 3
	sd.d += sd.y[i]

	
	(sd.d/sd.m, gnum)
end
