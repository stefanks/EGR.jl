module EGR

export MinusPlusOneVector, OutputOpts, alg, getStats, readBin, createBLOracles, L2regGradient, readData, writeBin, EGRsd, GDsd, SGsd, Opts, VerifyGradient, VerifyRestoration, findBestStepsizeFactor, createMLOracles, StepData, writeFunction, Outputter, ResultFromOO, Problem, returnIfExists, EGRexp, createSBLOracles, writeFinal, getF, getPCC, getMCC, normalizeFeatures, trainTestRandomSeparate, createClassLabels, getStatsHIGGSSUSY, readDataHIGGSSUSY, getStatsIRIS, readDataIRIS, readDataSparse, StrainTestRandomSeparate,DSSsd,DSSexp, getSequentialFinite, EGRexpBeta1, getRandom, SAGinit, getSampleFunctionAt, SAGAinit, SSVRG,EGRexpBeta2,EGRexpNatural,SSVRGsd,SSVRG,SSVRGfromEGR,SAG

include("MinusPlusOneVector.jl")
include("DataPrep.jl")
include("LossFunctions/lossBL.jl")
include("LossFunctions/lossSBL.jl")
include("LossFunctions/lossML.jl")
include("myIO.jl")
include("CreateOracles.jl")
include("LossFunctions/L2Reg.jl")
include("Alg.jl")
include("Steps/stepEGR.jl")
include("Steps/stepSG.jl")
include("Steps/stepDSS.jl")
include("Steps/stepGD.jl")
include("Steps/stepSAGinit.jl")
include("Steps/stepSAGAinit.jl")
include("Steps/stepSSVRG.jl")
include("Steps/stepSG.jl")
include("Steps/stepSAG.jl")
include("Steps/stepSAGA.jl")
include("FindBest.jl")
include("Producers.jl")
include("RedisStuff.jl")

end