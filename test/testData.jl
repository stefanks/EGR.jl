using Redis

(numDatapoints,minFeatureInd,numFeatures,numTotal,minfeature,maxfeature,numClasses) = getStats("data/agaricus/agaricus")
println("Number of datapoints = $numDatapoints")
println("minFeatureInd   = $minFeatureInd")
println("number of features   = $numFeatures")
println("numTotal   = $(numTotal)")
println("sparsity   = $(numTotal/(numDatapoints*numFeatures))")
println("minfeature   = $minfeature")
println("maxfeature   = $maxfeature")
println("numClasses   = $numClasses")

(features, labels) = readData("data/agaricus/agaricus", (numDatapoints,numFeatures), minFeatureInd)

# NORMALIZE FEATURES!!!
if (numTotal/(numDatapoints*numFeatures))>0.99 && (minfeature<-1.01 || maxfeature>1.01)
	minfeature=typemax(Int)
	maxfeature=typemin(Int)
	for i in 1:numFeatures
		thismax = maximum(features[:,i])
		thismin = minimum(features[:,i])
		features[:,i] =(2* features[:,i]-thismax-thismin)/(thismax-thismin)
		minfeature=min(minfeature, minimum(features[:,i] ))
		maxfeature=max(maxfeature, maximum(features[:,i] ))
	end
	println("After normalization")
	println("minfeature   = $minfeature")
	println("maxfeature   = $maxfeature")
end


client = RedisConnection();
Redis.hmset(client, "agaricus", {"name" => "agaricus", "path" => "data/agaricus/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" =>numTotal })

writeBin("data/agaricus/agaricus.bin", features, labels)

datasetHT=Redis.hgetall(client,"agaricus")

(features,labels) = readBin("data/agaricus/agaricus.bin",int(datasetHT["numDatapoints"]),int(datasetHT["numFeatures"]))

println()