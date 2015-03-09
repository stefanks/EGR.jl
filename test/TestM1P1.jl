using Base.Test
using EGR

println("TestM1P1")

a = MinusPlusOneVector([1,0,-1],Set([-1]))
b = MinusPlusOneVector([-1,-1,1])
@test a.field == b.field
@test a.numPlus == b.numPlus
@test_throws ArgumentError MinusPlusOneVector([1,1,-2])
@test_throws ArgumentError MinusPlusOneVector([1.0,1,-2])


println("TestM1P1 successful!")
println()