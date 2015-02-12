using Redis

(numDatapoints,minFeatureInd,numFeatures,numTotal,minfeature,maxfeature,numClasses) = getStats("data/Toy/Toy")
println("Number of datapoints = $numDatapoints")
println("minFeatureInd   = $minFeatureInd")
println("number of features   = $numFeatures")
println("numTotal   = $(numTotal)")
println("sparsity   = $(numTotal/(numDatapoints*numFeatures))")
println("minfeature   = $minfeature")
println("maxfeature   = $maxfeature")
println("numClasses   = $numClasses")

(features, labels) = readData("data/Toy/Toy", (numDatapoints,numFeatures), minFeatureInd)

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
Redis.hmset(client, "Toy", {"name" => "Toy", "path" => "data/Toy/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" =>numTotal })

writeBin("data/Toy/Toy.bin", features, labels)

datasetHT=Redis.hgetall(client,"Toy")

(features,labels) = readBin("data/Toy/Toy.bin",int(datasetHT["numDatapoints"]),int(datasetHT["numFeatures"]))

println()