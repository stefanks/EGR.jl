using Base.Test
using EGR

println("Testing MinusPlusOneVector")

a=MinusPlusOneVector([1,1,-1])
b=MinusPlusOneVector([1,1,-1.0])
c=MinusPlusOneVector([1,1,-1],Set([-1]))
println(a[1])
println(b[2:3])
println(c[[1,3]])
println(length(a))

@test_throws ArgumentError MinusPlusOneVector([1,1,-2])
@test_throws ArgumentError MinusPlusOneVector([1.0,1,-2])