module EGR

import Redis

import Base.size

export get_f_g_cs, get_f_pcc, get_g_from_cs, MinusPlusOneVector, OutputOpts, egr

include("MinusPlusOneVectorModule.jl")
include("BinaryLogisticRegressionModule.jl")
include("alg.jl")

println("testing redis")
client=Redis.redis();
datasetArray=Dict[]
for thisKey in Redis.smembers(client,"dataset_ids")
	push!(datasetArray,Redis.hgetall(client,thisKey))
end
sort!(datasetArray,by=x->int(x["numTotal"]))	
println(datasetArray)

end # module