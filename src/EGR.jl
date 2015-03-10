module EGR

export MinusPlusOneVector, OutputOpts, alg, getStats, readBin, createBLOracles, L2regGradient, readData, writeBin, EGRsd, GDsd, SGsd, Opts, VerifyGradient, VerifyRestoration, findBestStepsizeFactor, getSequential, createMLOracles, StepData, writeFunction, Outputter, ResultFromOO, Problem, returnIfExists, EGRexp, createSBLOracles, writeFinal, getF, getPCC, getMCC, normalizeFeatures, trainTestRandomSeparate, createClassLabels

include("MinusPlusOneVector.jl")
include("DataPrep.jl")
include("BL.jl")
include("SBL.jl")
include("ML.jl")
include("myIO.jl")
include("CreateOracles.jl")
include("L2Reg.jl")
include("Alg.jl")
include("ComputeStep.jl")
include("FindBest.jl")
include("Producers.jl")
include("RedisStuff.jl")

end