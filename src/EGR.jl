module EGR

export get_f_g_cs, get_f_pcc, get_g_from_cs, MinusPlusOneVector, OutputOpts, alg, getStats, readBin, createOracles, L2regGradient, readData, writeBin, gd, EGRsd, naturalEGRS, computeGDStep, GDsd, SGsd, computeSGStep, Opts

include("MinusPlusOneVector.jl")
include("BinaryLogisticRegression.jl")
include("myIO.jl")
include("CreateOracles.jl")
include("L2Reg.jl")
include("ComputeStep.jl")
include("Alg.jl")

end