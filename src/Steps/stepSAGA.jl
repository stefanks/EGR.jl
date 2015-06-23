type SAGAsd <: StepData
	A
	y
	m::Int64
	numChunks::Int64
	getStep::Function
	stepString::String
	shortString::String
	function SAGAsd(numVars::Int64,y, stepString::String, shortString::String,numDp::Int64,numChunks::Int64)
		A = sum(y)
		new(A, y, numDp, numChunks, SAGAComputation, stepString, shortString)
	end
end

function SAGA(numVars::Int64, y, numDP::Int64,numChunks::Int64)
	SAGAsd(numVars,y, "SAGA.$numChunks", "SAGA.$numChunks", numDP,numChunks)
end


function SAGAComputation(x, k, gnum, sd::SAGAsd, problem::Problem; outputLevel =0 )

	outputLevel >0 && println("SAGAComputation started")

	i = rand(1:sd.numChunks)
	
	# step 1
	B = copy(sd.y[i])
	sd.y[i] = zeros(sd.y[i])
			   
	# step 2
	for j in (i-1)*int(floor(sd.m/sd.numChunks))+1:i*int(floor(sd.m/sd.numChunks))
		outputLevel >1 && println(" Inner loop, j = $j")
		(f,sampleG) = (problem.getSampleFunctionAt(j))(x)
		sd.y[i]+=sampleG
		gnum += 1
	end
	
	#step 3

	outputLevel >0 && println("Acutal step determination")
	# println(typeof(sd.m))
	# println(typeof(sd.A))
	# println(typeof(sd.numChunks))
	# println(typeof(B))
	# println(typeof(sd.y[i]))
	step =((1/sd.m)*sd.A) - (sd.numChunks/sd.m)*(B - sd.y[i] )
	

	outputLevel >0 && println("Updating current sum")
	sd.A=sd.A-B+sd.y[i]
	outputLevel >0 && println("SAGAComputation finished")
	(step,gnum)
	
	
	
end
