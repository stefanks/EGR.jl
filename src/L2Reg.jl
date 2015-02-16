function L2regGradient(gradientOracle::Function, L2param::Float64, W,b)
	
	res = gradientOracle(W,b)

	( res[1] + (1/2)*L2param*norm(W)^2,res[2]+ L2param*W, res[3])
end

function L2regGradient(gradientOracle::Function, L2param::Float64, W)
	
	res = gradientOracle(W)

	( res[1] + (1/2)*L2param*norm(W)^2,res[2]+ L2param*W, res[3])
end