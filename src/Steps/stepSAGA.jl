type SAGAsd <: StepData
	A
	y
	m::Int64
	numChunks::Int64
	batchSize::Int64
	getStep::Function
	stepString::String
	shortString::String
	function SAGAsd(numVars::Int64,y, stepString::String, shortString::String,numDp::Int64,numChunks::Int64, batchSize::Int64)
		A = sum(y)
		new(A, y, numDp, numChunks,batchSize, SAGAComputation, stepString, shortString)
	end
end

function SAGA(numVars::Int64, y, numDP::Int64,numChunks::Int64,batchSize::Int64)
	SAGAsd(numVars,y, "SAGA.$numChunks.$batchSize", "SAGA.$numChunks.$batchSize", numDP,numChunks,batchSize)
end


function SAGAComputation(x, k, gnum, sd::SAGAsd, problem::Problem; outputLevel =0 )

	outputLevel >0 && println("SAGAComputation started")

	B=zeros(size(x))
	
	sumy=zeros(size(x))

	indices = sample(1:sd.numChunks,sd.batchSize;replace=false)
	nummm=0
	for i in indices

		B +=sd.y[i]
	
		sd.y[i]=zeros(size(x))
			   
		for j in (i-1)*int(floor(sd.m/sd.numChunks))+1:i*int(floor(sd.m/sd.numChunks))
			outputLevel >1 && println(" Inner loop, j = $j")
			(f,sampleG) = (problem.getSampleFunctionAt(j))(x)
			sd.y[i]+=sampleG
			sumy += sampleG
			nummm +=1
			gnum += 1
		end
	
		#step 3
	end
	outputLevel >0 && println("Acutal step determination")
	
	step =((1/sd.m)*sd.A) - (1/nummm)*(B - sumy )
	

	outputLevel >0 && println("Updating current sum")
	sd.A=sd.A-B+sumy
	outputLevel >0 && println("SAGAComputation finished")
	(step,gnum)
	
	
	
end
