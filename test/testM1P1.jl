
function M1P1Test()
	a=MinusPlusOneVector([1,1,-1])
	b=MinusPlusOneVector([1,1,-1.0])
	c=MinusPlusOneVector([1,1,-1],Set([-1]))	
	println(a[1])
	println(b[2:3])
	println(c[[1,3]])
	println(size(a))
	true
end


@test M1P1Test()