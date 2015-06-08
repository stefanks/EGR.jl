type SAGAinitsd <: StepData
	d
	functions
	y
	I
	getStep::Function
	stepString::String
	shortString::String
	function SAGAinitsd(numVars::Int64,dt::DataType, stepString::String, shortString::String,numDp::Int64)
		new(zeros(numVars),Array((Function,Function), numDp), Array(dt, numDp),0,  SAGAinitComputation, stepString, shortString)
	end
end

function SAGAinit(numVars::Int64, dt::DataType, numDP::Int64)
	SAGAinitsd(numVars,dt, "SAGAinit", "SAGAinit", numDP)
end


function SAGAinitComputation(x, k, gnum, sd::SAGAinitsd, problem::Problem; outputLevel =0)

	i = rand(1:problem.numTrainingPoints)

	step = sd.d
	
	# step 1
	try
		oldG = sd.functions[i][2](sd.y[i])
		sd.d -= oldG

		(f,sampleG,cs) = (sd.functions[i][1])(x)
		sd.y[i] = cs
		gnum += 1
		sd.d += sampleG
		
		step = sampleG - oldG + origSum/sd.I 
	catch
		sd.functions[i] = problem.getSampleFunctionAt(i)
		sd.I+=1

		(f,sampleG,cs) = (sd.functions[i][1])(x)
		sd.y[i] = cs
		gnum += 1
		sd.d += sampleG
		
		step = sampleG
	end
			 

	
	(step, gnum)
end
