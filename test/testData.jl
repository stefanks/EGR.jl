using Redis

(n,minFeatureInd,maxFeatureInd,numTotal,minfeature,maxfeature) = getStats("data/agaricus/agaricus")
println("Number of datapoints = $n")
println("minFeatureInd   = $minFeatureInd")
println("maxFeatureInd   = $maxFeatureInd")
println("number of features   = $(maxFeatureInd-minFeatureInd+1)")
println("numTotal   = $(numTotal)")
println("sparsity   = $(numTotal/(n*(maxFeatureInd-minFeatureInd+1)))")
println("minfeature   = $minfeature")
println("maxfeature   = $maxfeature")


client = RedisConnection();
Redis.hmset(client, "testDataset:1", {"name" => "agaricus", "path" => "data/agaricus/", "nDatapoints" => n, "nFeatures" => maxFeatureInd-minFeatureInd+1,"minFeatureInd" => minFeatureInd, "minFeature" => minfeature, "maxFeature"=>maxfeature , "numTotal" =>numTotal })

Redis.sadd(client, "test_dataset_ids", "testDataset:1")

datasetArray=Dict[]
for thisKey in Redis.smembers(client,"test_dataset_ids")
	push!(datasetArray,Redis.hgetall(client,thisKey))
end
sort!(datasetArray,by=x->int(x["numTotal"]))

datasetHT = datasetArray[1]

readWrite("data/agaricus/agaricus",datasetHT)

(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin",int(datasetHT["nDatapoints"]),int(datasetHT["nFeatures"]))