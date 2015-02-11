module EGR

export get_f_g_cs, get_f_pcc, get_g_from_cs, MinusPlusOneVector, OutputOpts, egr, getStats, readWrite, readBin

include("MinusPlusOneVector.jl")
include("BinaryLogisticRegression.jl")
include("alg.jl")
include("myIO.jl")

end