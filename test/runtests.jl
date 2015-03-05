try 
	cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end

tic()
using EGR
toc()

println("Running tests:")

# include("Test1.jl")

println("Loading data, separating into testing and training")

FullDict = Dict()

# testProblems = ["TestToy","TestAgaricus"]
# testProblems = ["TestToy"]
# testProblems = ["TestAgaricus"]
# include("LoadData.jl")

include("LoadDataAlt.jl")

println("Data dependent tests")

include("Test3.jl")

println("Create problems")

Problems = Problem[]
include("CreateProblems.jl")

println("Problem dependent tests")

include("Test5.jl")
include("Test6.jl")