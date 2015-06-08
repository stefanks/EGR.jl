function L2regGradient(gradientOracle::Function, L2param::Float64, W::Matrix{Float64}, index::Int64)
	(f,g,ym) = gradientOracle(W,index)
	newG = g+ L2param*W
	(f + (1/2)*L2param*norm(W)^2, newG, newG)
end

function L2regGradient(gradientOracle::Function, L2param::Float64, W::Matrix{Float64})
	(f,g) = gradientOracle(W)
	(f+ (1/2)*L2param*norm(W)^2,g+ L2param*W)
end

function L2RestoreGradient(restoreGradient::Function, L2param::Float64, cs::Union(Float64,Matrix{Float64}), index::Int64)
	cs
end
