using Base.Test
using EGR

try 
cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end
my_tests = [ "testData.jl", "testM1P1.jl", "testGradient.jl", "testEGR.jl", "testGD.jl"]
# my_tests = ["testData.jl", "testEGR.jl"]

for my_test in my_tests
  include(my_test)
  println("Test $my_test passed!")
end