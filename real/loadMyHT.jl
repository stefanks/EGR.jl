println("Loading Redis and EGR")
tic()
using EGR
using Redis
toc()
println("Reading datasetArray from database")
@time begin
	client = RedisConnection();
	datasetArray=Dict[]
	for thisKey in Redis.smembers(client,"dataset_ids")
		push!(datasetArray,Redis.hgetall(client,thisKey))
	end
	sort!(datasetArray,by=x->int(x["numTotal"]))
end