try
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

using EGR

include("TestM1P1.jl")
include("TestRedisReadWrite.jl")

Oracles = Tuple{Function,Int64,Int64,DataType,ASCIIString,Outputter,Bool,ASCIIString,Function}[]
include("LoadTestToyData.jl")
include("LoadTestToySparseData.jl")
include("LoadTestAgaricusData.jl")

include("TestVerify.jl")
include("TestEGRlikeSG.jl")
include("TestFindBest.jl")
include("TestRedisRuns.jl")
include("TestSSVRG.jl")
include("TestSAG.jl")
include("TestSAGA.jl")
include("TestSAGAinit.jl")
include("TestSAGinit.jl")
include("TestUniversal.jl") 