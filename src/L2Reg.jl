function L2regGradient(gradientOracle::Function, L2param::Float64, a,b)

 	W = a
	
	res = gradientOracle(a,b)
	
	( res[1] + (1/2)*L2param*(W'*W),res[2]+ L2param*W, res[3])

end