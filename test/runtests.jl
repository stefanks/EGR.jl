try
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

using EGR

include("TestM1P1.jl")
include("TestRedisReadWrite.jl")

Oracles = (Function,Int64,Int64,Function,DataType,ASCIIString,Outputter,Bool,ASCIIString,Function,Any)[]
include("LoadTestToyData.jl")
include("LoadTestAgaricusData.jl")
include("LoadTestSparseData.jl")
include("LoadTestFarmData.jl")

# include("TestVerify.jl")
# include("TestRestore.jl")
include("TestEGRlikeGD.jl")
include("TestEGRlikeSG.jl")
include("TestFindBest.jl")
include("TestRedisRuns.jl")