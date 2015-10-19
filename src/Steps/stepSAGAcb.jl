type SAGAcbsd <: StepData
	A
	y
	m::Int64
	numClasses::Int64
	c::Vector{Int64}
	batchSize::Int64
	getStep::Function
	stepString::AbstractString
	function SAGAcbsd(numVars::Int64,y, stepString::AbstractString,numDp::Int64, batchSize::Int64,c)
		A = sum(y)
		new(A, y, numDp, size(y)[1],c,batchSize, SAGAcbComputation, stepString)
	end
end

function SAGAcb(numVars::Int64, y,batchSize::Int64, c, numDP::Int64)
	SAGAcbsd(numVars,y, "SAGAcb.$batchSize", numDP,batchSize,c)
end

function SAGAcbComputation(x, k, gnum, sd::SAGAcbsd, problem::Problem; outputLevel =0 )

	outputLevel >0 && println("SAGAcbComputation started")

	B=zeros(size(x))

	sumy=zeros(size(x))

	indices = sample(1:sd.m,sd.batchSize;replace=false)
	nummm=0
	for i in indices

		B +=sd.y[sd.c[i]]
		(f,sampleG) = (problem.getSampleFunctionAt(i))(x)
		sd.y[sd.c[i]]=sampleG
		sumy += sampleG
		nummm +=1
		gnum += 1

		#step 3
	end
	outputLevel >0 && println("Acutal step determination")

	step =((1/sd.numClasses)*sd.A) - (1/nummm)*(B - sumy)


	outputLevel >0 && println("Updating current sum")
	sd.A=sd.A-B+sumy
	outputLevel >0 && println("SAGAcbComputation finished")
	(step,gnum)

end
