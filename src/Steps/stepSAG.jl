type SAGsd <: StepData
	d
	functions
	y
	chunks
	m::Int64
	getStep::Function
	stepString::String
	shortString::String
	function SAGsd(numVars::Int64,dt::DataType, stepString::String, shortString::String,numDp::Int64)
		new(zeros(numVars),Array(Function, numDp), Array(dt, numDp),Array([] , numChunks), numDp, SAGComputation, stepString, shortString)
	end
end

function SAG(numVars::Int64, dt::DataType, numDP::Int64)
	SAGsd(numVars,dt, "SAG", "SAG", numDP)
end


function SAGComputation(x, k, gnum, sd::SAGinitsd, problem::Problem; outputLevel =0)

	i = rand(1:sd.numChunks)
	
	# step 1
	sd.d -= sd.y[i]
	sd.y[i] = zeros(problem.numVars)
			   
	# step 2
	for j in sd.chunks[i]
		(f,sampleG) = (sd.functions[i])(x)
		gnum += 1
	end
	
	#step 3
	sd.d += sampleG

	
	(sd.d/sd.m, gnum)
end
