function getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	indices = [1:numTrainingPoints;]
	while true
		for i in indices
			let j=i
				gg=(x)-> gradientOracle(x,j)
				ccs=(cs)-> restoreGradient(cs,j)
				produce((gg,ccs))
			end
		end
		shuffle!(indices)
	end
end