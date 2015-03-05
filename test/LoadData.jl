#
# using Redis
#
#
# sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
# uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0
#
# println("Starting Redis connection")
# client = RedisConnection();
#
# run(`redis-cli keys "TestToy:*"` |> `xargs redis-cli del`);
# run(`redis-cli keys "TestAgaricus:*"` |> `xargs redis-cli del`);
#
# testProblems = ["TestToy"]
#
# testProblems = ["TestAgaricus"]
#

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


	Redis.hmset(client, testProblem, {"name" => testProblem, "path" => "data/"*testProblem*"/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" =>numTotal })

	println("Writing binary file")

	writeBin("data/"*testProblem*"/"*testProblem*".bin", features, labels)

	datasetHT=Redis.hgetall(client,testProblem)

	println("Reading binary file")

	(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin", int(datasetHT["numDatapoints"]), int(datasetHT["numFeatures"]))
	
	FullDict[testProblem] = {"features"=> features ,"labels"=> labels}
end