function shuffle!(r::AbstractRNG, a::AbstractVector)
	for i = length(a):-1:2
		j=int(floor(rand(r)*i)+1)
		a[i], a[j] = a[j], a[i]
	end
	return a
end

function getSequential(numTrainingPoints::Int64,gradientOracle)
	indices = [1:numTrainingPoints;]
	r = MersenneTwister(1)
	while true
		for i in indices
			let j=i
				gg=(x)-> gradientOracle(x,j)
				produce(gg)
			end
		end
		shuffle!(r, indices)
	end
end


function getSequentialFinite(numTrainingPoints::Int64,gradientOracle)
	indices = [1:numTrainingPoints;]
	for i in indices
		let j=i
			gg=(x)-> gradientOracle(x,j)
			produce(gg)
		end
	end
end

function getRandom(numTrainingPoints::Int64,gradientOracle)
    while true
		i = rand(1:numTrainingPoints)
		let j=i
			gg=(x)-> gradientOracle(x,j)
			produce(gg)
		end
	end
end

function getSampleFunctionAt(j::Int64, gradientOracle)
	(x)-> gradientOracle(x,j)
end
