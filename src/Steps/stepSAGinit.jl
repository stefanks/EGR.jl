type SAGinitsd <: StepData
	d
	functions
	y
	I
	getStep::Function
	stepString::String
	function SAGinitsd(numVars::Int64,dt::DataType, stepString::String,numDp::Int64)
		new(zeros(numVars),Array(Function, numDp), Array(dt, numDp),0,  SAGinitComputation, stepString)
	end
end

function SAGinit(numVars::Int64, dt::DataType, numDP::Int64)
	SAGinitsd(numVars,dt, "SAGinit",  numDP)
end


function SAGinitComputation(x, k, gnum, sd::SAGinitsd, problem::Problem; outputLevel =0)

	i = rand(1:problem.numTrainingPoints)
	
	# step 1
	try
		sd.d -= sd.y[i]
	catch
		sd.functions[i] = problem.getSampleFunctionAt(i)
		sd.I+=1
	end
			   
		
	# step 2
	(f,sampleG) = (sd.functions[i])(x)
	sd.y[i] = sampleG
	gnum += 1
	
	#step 3
	sd.d += sampleG

	
	(sd.d/sd.I, gnum)
end
