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


function SAGAComputation(x, k, gnum, sd::SAGAsd, problem::Problem; outputLevel =0)


	
	#
	# oldG = sd.functions[i][2](sd.y[i])
	# step=sd.d/sd.I - oldG
	# sd.d -= oldG
	#
	# (f,sampleG,cs) = (sd.functions[i][1])(x)
	# sd.y[i] = cs
	# gnum += 1
	# sd.d += sampleG
	#
	# step = step + sampleG


	i = rand(1:sd.numChunks)
	
	# step 1
	oldG = sd.y[i]
	step =sd.d/sd.m -oldG*(sd.m/sd.numChunks)
	sd.d -= oldG
	sd.y[i] = zeros(sd.y[i] )
			   
	# step 2
	for j in (i-1)*int(floor(sd.m/sd.numChunks))+1:i*int(floor(sd.m/sd.numChunks))
		(f,sampleG) = (problem.getSampleFunctionAt(j))(x)
		sd.y[i]+=sampleG
		gnum += 1
	end
	
	#step 3
	sd.d += sd.y[i]
	
	(step + sd.y[i]*(sd.m/sd.numChunks), gnum)
end
