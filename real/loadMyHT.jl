using Redis

client = RedisConnection();
datasetArray=Dict[]
for thisKey in Redis.smembers(client,"dataset_ids")
	push!(datasetArray,Redis.hgetall(client,thisKey))
end
sort!(datasetArray,by=x->int(x["numTotal"]))