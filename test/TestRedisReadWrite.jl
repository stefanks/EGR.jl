using EGR
using Redis

println("TestRedisReadWrite")

client = RedisConnection();

(numDatapoints,minFeatureInd,numFeatures,numTotal,minfeature,maxfeature,numClasses) = getStats("data/TestAgaricus/TestAgaricus")
println(" Number of datapoints = $numDatapoints")
println(" minFeatureInd   = $minFeatureInd")
println(" number of features   = $numFeatures")
println(" numTotal   = $(numTotal)")
println(" sparsity   = $(numTotal/(numDatapoints*numFeatures))")
println(" minfeature   = $minfeature")
println(" maxfeature   = $maxfeature")
println(" numClasses   = $numClasses")

(features, labels) = readData("data/TestAgaricus/TestAgaricus", (numDatapoints,numFeatures), minFeatureInd)

Redis.hmset(client, "TestAgaricus", Dict{Any,Any}("name" => "TestAgaricus", "path" => "data/TestAgaricus/", "numDatapoints" => numDatapoints, "numFeatures" => numFeatures, "minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature, "numTotal" => numTotal ))

println(" Writing binary file")

writeBin("data/TestAgaricus/TestAgaricus.bin", features, labels)

datasetHT=Redis.hgetall(client,"TestAgaricus")

println(" Reading binary file")
#
(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin", parse(Int,datasetHT["numDatapoints"]), parse(Int,datasetHT["numFeatures"]))

println("TestRedisReadWrite successful!")
println()