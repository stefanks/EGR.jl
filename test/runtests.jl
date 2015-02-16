using Base.Test
using EGR
using Redis
try 
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0

function getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	indices = [1:numTrainingPoints;]
	# println("A call to getSequential ")
	while true
		for i in indices
			# println("i = $i")
			# println(typeof(gradientOracle))
			# println(methods(gradientOracle))
			gg(x) = gradientOracle(x,i)
			ccs(cs) = restoreGradient(cs,i)
			# println("Ready to produce")
			produce((gg,ccs))
		end
		shuffle!(indices)
	end
end

testProblems={"Toy","agaricus"}

for testProblem in testProblems

	(numDatapoints,minFeatureInd,numFeatures,numTotal,minfeature,maxfeature,numClasses) = getStats("data/"*testProblem*"/"*testProblem)
	println("Number of datapoints = $numDatapoints")
	println("minFeatureInd   = $minFeatureInd")
	println("number of features   = $numFeatures")
	println("numTotal   = $(numTotal)")
	println("sparsity   = $(numTotal/(numDatapoints*numFeatures))")
	println("minfeature   = $minfeature")
	println("maxfeature   = $maxfeature")
	println("numClasses   = $numClasses")

	(features, labels) = readData("data/"*testProblem*"/"*testProblem, (numDatapoints,numFeatures), minFeatureInd)

	# NORMALIZE FEATURES!!!
	if (numTotal/(numDatapoints*numFeatures))>0.99 && (minfeature<-1.01 || maxfeature>1.01)
		minfeature=typemax(Int)
		maxfeature=typemin(Int)
		for j in 1:numFeatures
			thismax = maximum(features[:,j])
			thismin = minimum(features[:,j])
			features[:,j] =(2* features[:,j]-thismax-thismin)/(thismax-thismin)
			minfeature=min(minfeature, minimum(features[:,j] ))
			maxfeature=max(maxfeature, maximum(features[:,j] ))
		end
		println("After normalization")
		println("minfeature   = $minfeature")
		println("maxfeature   = $maxfeature")
	end

	println("Starting Redis connection")
	client = RedisConnection();
	Redis.hmset(client, testProblem, {"name" => testProblem, "path" => "data/"*testProblem*"/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" =>numTotal })

	println("Writing binary file")

	writeBin("data/"*testProblem*"/"*testProblem*".bin", features, labels)

	datasetHT=Redis.hgetall(client,testProblem)

	println("Reading binary file")

	(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin", int(datasetHT["numDatapoints"]), int(datasetHT["numFeatures"]))

	println()

	for L2reg in [false; true]
		
		
		(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient) = createOracles(features,labels,int(datasetHT["numDatapoints"]), int(datasetHT["numFeatures"]),Set([1.0]); L2reg=L2reg,outputLevel=0)

		VerifyGradient(numVars,gradientOracle,numTrainingPoints)
	
		println("If s(k) = 0 and then numTrainingPoints, u(k) = numTrainingPoints, then 0 , gamma is natural, then egrs is equivalent to gd!!!")

		stepSize(k)=0.1
		s(k,I) = sLikeGd(k,numTrainingPoints)
		u(k,I) =  uLikeGd(k,numTrainingPoints)
		beta(k) =1 - 1/sqrt(k+1)

		maxG = 10*numTrainingPoints


		getNextSampleFunction = Task(() -> getSequential(numTrainingPoints,gradientOracle,restoreGradient))
	
		println(consume(getNextSampleFunction))

		alg(Opts(zeros(numVars),stepSize; maxG=maxG), EGRsd(s, u, beta, getNextSampleFunction,numVars),  OutputOpts(outputsFunction,outputLevel=2))

		getFullGradient(W) = gradientOracle(W)

		alg(Opts(zeros(numVars),stepSize; maxG=maxG), GDsd(getFullGradient, numTrainingPoints),  OutputOpts(outputsFunction,outputLevel=2))

		stepSize(k)=0.1




		println("If s(k) = 0, u(k) = 1, gamma is natural, then egrs is equivalent to sgs!!!")



		alg(Opts(zeros(numVars),stepSize; maxG=maxG), SGsd(getNextSampleFunction), OutputOpts(outputsFunction,outputLevel=2))

		s(k,I)=0
		u(k,I)= 1

		alg(Opts(zeros(numVars),stepSize; maxG=maxG), EGRsd(s, u, beta, getNextSampleFunction,numVars), OutputOpts(outputsFunction,outputLevel=2))

	end
end

println("Testing MinusPlusOneVector")

a=MinusPlusOneVector([1,1,-1])
b=MinusPlusOneVector([1,1,-1.0])
c=MinusPlusOneVector([1,1,-1],Set([-1]))	
println(a[1])
println(b[2:3])
println(c[[1,3]])
println(size(a))


