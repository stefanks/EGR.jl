#
using Redis
#
#
# sLikeGd(k,numTrainingPoints) = k==0 ? 0 : numTrainingPoints
# uLikeGd(k,numTrainingPoints) = k==0 ? numTrainingPoints : 0
#
# println("Starting Redis connection")
#
# run(`redis-cli keys "TestToy:*"` |> `xargs redis-cli del`);
# run(`redis-cli keys "TestAgaricus:*"` |> `xargs redis-cli del`);
#
# testProblems = ["TestToy"]
#
# testProblems = ["TestAgaricus"]
#

function LoadAgaricusData()
	

	println("In LoadAgaricusData")

	client = RedisConnection();
	
	(numDatapoints,minFeatureInd,numFeatures,numTotal,minfeature,maxfeature,numClasses) = getStats("data/TestAgaricus/TestAgaricus")
	println("Number of datapoints = $numDatapoints")
	println("minFeatureInd   = $minFeatureInd")
	println("number of features   = $numFeatures")
	println("numTotal   = $(numTotal)")
	println("sparsity   = $(numTotal/(numDatapoints*numFeatures))")
	println("minfeature   = $minfeature")
	println("maxfeature   = $maxfeature")
	println("numClasses   = $numClasses")

	(features, labels) = readData("data/TestAgaricus/TestAgaricus", (numDatapoints,numFeatures), minFeatureInd)


	Redis.hmset(client, "TestAgaricus", {"name" => "TestAgaricus", "path" => "data/TestAgaricus/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" => numTotal })

	println("Writing binary file")

	writeBin("data/TestAgaricus/TestAgaricus.bin", features, labels)

	datasetHT=Redis.hgetall(client,"TestAgaricus")

	println("Reading binary file")
	#
	(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin", int(datasetHT["numDatapoints"]), int(datasetHT["numFeatures"]))

	(classLabels, numClasses) = createClassLabels(labels)

	(trf, trl, trl2, numTrainingPoints, tef, tel, tel2) = trainTestRandomSeparate(features, MinusPlusOneVector(labels, Set([1.0])), classLabels)

	dict = {"trf"=> trf, "trl"=> trl, "trl2"=> trl2, "numTrainingPoints" => numTrainingPoints, "tef" => tef, "tel" => tel, "tel2" => tel2, "name" => "TestAgaricus", "numClasses" => numClasses}

end


FullDict["TestAgaricus"] = LoadAgaricusData()