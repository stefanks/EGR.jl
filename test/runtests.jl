using Base.Test
using EGR

try 
cd(Pkg.dir("EGR"))
end

(numVars, numDatapoints,gradientFunction, restoreGradient,outputsFunction)=Generate6dpProblem()

my_tests = [ "testData.jl", "testM1P1.jl", "testEGR.jl", "testGradient.jl"]

for my_test in my_tests
  include(my_test)
  println("Test $my_test passed!")
end