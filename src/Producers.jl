function shuffle!(r::AbstractRNG, a::AbstractVector)
	for i = length(a):-1:2
		j=int(floor(rand(r)*i)+1)
		a[i], a[j] = a[j], a[i]
	end
	return a
end

function getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	indices = [1:numTrainingPoints;]
	r = MersenneTwister(1)
	while true
		for i in indices
			let j=i
				# println(i)
				gg=(x)-> gradientOracle(x,j)
				ccs=(cs)-> restoreGradient(cs,j)
				produce((gg,ccs))
			end
		end
		# println("Shuffling!")
		shuffle!(r, indices)
		# shuffle!(indices)
	end
end