using Base.Test
using EGR

try 
cd(Pkg.dir("EGR"))
catch
	cd("/Users/stepa/Google Drive/Research/EGRproject/EGR.jl")
end
println(pwd())
my_tests = [ "testData.jl", "testM1P1.jl", "testEGR.jl", "testGradient.jl"]

for my_test in my_tests
  include(my_test)
  println("Test $my_test passed!")
end
