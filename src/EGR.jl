module EGR

export get_f_g_cs, get_f_pcc, get_g_from_cs, MinusPlusOneVector, OutputOpts, egr, getStats, readBin, createOracles, L2regGradient, readData, writeBin, gd

include("MinusPlusOneVector.jl")
include("BinaryLogisticRegression.jl")
include("alg.jl")
include("myIO.jl")
include("CreateOracles.jl")
include("L2Reg.jl")

end