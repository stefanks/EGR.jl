function L2regGradient(gradientOracle::Function, L2param::Float64, W,b)
	res = gradientOracle(W,b)
	g= res[2]+ L2param*W
	( res[1] + (1/2)*L2param*norm(W)^2,g,g)
end

function L2regGradient(gradientOracle::Function, L2param::Float64, W)
	res = gradientOracle(W)
	g= res[2]+ L2param*W
	( res[1] + (1/2)*L2param*norm(W)^2,g,g)
end

function L2RestoreGradient(restoreGradient::Function, L2param::Float64, a,b)
	a
end
