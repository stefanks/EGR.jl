module EGR

export BL_get_f_g, BL_restore_gradient, BL_for_output, MinusPlusOneVector, OutputOpts, alg, getStats, readBin, createBLOracles, L2regGradient, readData, writeBin, EGRsd, GDsd, SGsd, Opts, VerifyGradient, VerifyRestoration, findBestStepsizeFactor, getSequential, createMLOracles, ML_for_output

include("MinusPlusOneVector.jl")
include("BinaryLogisticRegression.jl")
include("MulticlassLogisticRegression.jl")
include("myIO.jl")
include("CreateOracles.jl")
include("L2Reg.jl")
include("ComputeStep.jl")
include("Alg.jl")
include("Verify.jl")
include("FindBest.jl")
include("Producers.jl")

end