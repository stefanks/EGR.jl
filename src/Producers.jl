function shuffle!(r::AbstractRNG, a::AbstractVector)
	for i = length(a):-1:2
		j=int(floor(rand(r)*i)+1)
		a[i], a[j] = a[j], a[i]
	end
	return a
end

function getSequential(numTrainingPoints::Int64,gradientOracle,restoreGradient)
	indices = [1:numTrainingPoints;]
	r = MersenneTwister(1)
	while true
		for i in indices
			let j=i
				# println(i)
				gg=(x)-> gradientOracle(x,j)
				produce(gg)
			end
		end
		# println("Shuffling!")
		shuffle!(r, indices)
		# shuffle!(indices)
	end
end


function getSequentialFinite(numTrainingPoints::Int64,gradientOracle,restoreGradient)
	indices = [1:numTrainingPoints;]
	for i in indices
		let j=i
			gg=(x)-> gradientOracle(x,j)
			produce(gg)
		end
	end
end

function getRandom(numTrainingPoints::Int64,gradientOracle,restoreGradient)
    while true
		i = rand(1:numTrainingPoints)
		let j=i
			gg=(x)-> gradientOracle(x,j)
			produce(gg)
		end
	end
end

function getSampleFunctionAt(j::Int64,gradientOracle,restoreGradient)
		gg=(x)-> gradientOracle(x,j)
		gg
end