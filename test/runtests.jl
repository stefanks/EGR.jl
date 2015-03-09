try
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

using EGR

include("TestM1P1.jl")

Oracles = (Function,Int64,Int64,Function,DataType,ASCIIString,Outputter,Bool,ASCIIString,Function)[]
include("LoadTestToyData.jl")
include("LoadTestAgaricusData.jl")

include("TestVerify.jl")
include("TestRestore.jl")
include("TestEGRlikeGD.jl")
include("TestEGRlikeSG.jl")
include("Test7.jl")
include("TestRedis.jl")