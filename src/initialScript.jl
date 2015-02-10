println("Starting InitialScript.")
using StatsBase
using Redis
client=redis();
datasetArray=Dict[]
for thisKey in smembers(client,"dataset_ids")
	push!(datasetArray,hgetall(client,thisKey))
end
sort!(datasetArray,by=x->int(x["numTotal"]))	
println("Done with InitialScript.")