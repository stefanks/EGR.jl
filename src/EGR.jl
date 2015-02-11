module EGR

using Redis

import Base.size

export get_f_g_cs, get_f_pcc, get_g_from_cs, MinusPlusOneVector, OutputOpts, egr, Generate6dpProblem, getStats

include("MinusPlusOneVector.jl")
include("BinaryLogisticRegression.jl")
include("alg.jl")
include("getDataStats.jl")
include("Generate6dpProblem.jl")
include("myIO.jl")

# client = RedisConnection();
# datasetArray=Dict[]
# for thisKey in Redis.smembers(client,"dataset_ids")
# 	push!(datasetArray,Redis.hgetall(client,thisKey))
# end
# sort!(datasetArray,by=x->int(x["numTotal"]))

end