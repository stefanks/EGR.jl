type SAGAinitsd <: StepData
	d
	functions
	y
	I
	getStep::Function
	stepString::String
	shortString::String
	function SAGAinitsd(numVars::Int64,dt::DataType, stepString::String, shortString::String,numDp::Int64)
		new(zeros(numVars),Array(Function, numDp), Array(dt, numDp),0,  SAGAinitComputation, stepString, shortString)
	end
end

function SAGAinit(numVars::Int64, dt::DataType, numDP::Int64)
	SAGAinitsd(numVars,dt, "SAGAinit", "SAGAinit", numDP)
end


function SAGAinitComputation(x, k, gnum, sd::SAGAinitsd, problem::Problem; outputLevel =0)

	outputLevel >0 && println("In SAGAinitComputation")
	i = rand(1:problem.numTrainingPoints)

	step = sd.d
	
	# step 1
	try
		outputLevel >0 && println("Trying to do full SAGA update")
		oldG = sd.y[i]
		step=sd.d/sd.I - oldG
		sd.d -= oldG

		(f,sampleG) = (sd.functions[i])(x)
		sd.y[i] = sampleG
		gnum += 1
		sd.d += sampleG
		step = step + sampleG
		
	catch
		outputLevel >0 && println("Falling back on SG")
		sd.functions[i] = problem.getSampleFunctionAt(i)
		outputLevel >0 && println("Added a function")
		sd.I+=1

		(f,sampleG) = (sd.functions[i])(x)
		outputLevel >0 && println("Computed new gradient")
		sd.y[i] = sampleG
		outputLevel >0 && println("Stored in y")
		gnum += 1
		sd.d += sampleG
		
		step = sampleG
	end
			 

	outputLevel >0 && println("Finishing SAGAinitComputation")
	
	(step, gnum)
end
