# function shuffle!(r::AbstractRNG, a::AbstractVector)
#     for i = length(a):-1:2
#         j = rand(r, 1:i)
#         a[i], a[j] = a[j], a[i]
#     end
#     return a
# end

function getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	indices = [1:numTrainingPoints;]
	# r = MersenneTwister(1)
	while true
		for i in indices
			let j=i
				gg=(x)-> gradientOracle(x,j)
				ccs=(cs)-> restoreGradient(cs,j)
				produce((gg,ccs))
			end
		end
		# shuffle!(r, indices)
		shuffle!(indices)
	end
end