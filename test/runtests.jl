try
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

tic()
using EGR
toc()

println("Running tests:")

include("Test1.jl")

println("Loading data, separating into testing and training")

FullDict = Dict()

include("LoadDataAlt.jl")

include("LoadData.jl")

println("Data dependent tests")

include("Test3.jl")

println("Create oracles")

Oracles = (Function,Int64,Int64,Function,DataType,ASCIIString,Outputter,Bool,ASCIIString,Function)[]

include("CO.jl")

println("Oracle dependent tests")

include("Test4.jl")

println("Problem dependent tests")

include("Test5.jl")
include("Test6.jl")
include("Test7.jl")
include("TestRedis.jl")
