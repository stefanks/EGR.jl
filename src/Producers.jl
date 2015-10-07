function shuffle!(r::AbstractRNG, a::AbstractVector)
	for i = length(a):-1:2
		j=int(floor(rand(r)*i)+1)
		a[i], a[j] = a[j], a[i]
	end
	return a
end

function getSequential(numTP::Int64,gradientOracle)
	indices = [1:numTP;]
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


function getSequentialR(numTP::Int64,gradientOracle,restoreFunc)
	# println("Start of producer")
	indices = [1:numTP;]
	r = MersenneTwister(1)
	while true
		for i in indices
			let j=i
				# println("before gg assign")
				gg=(x)-> gradientOracle(x,j)
				rf=(cs)-> restoreFunc(cs,j)
				# println("before produce in producer")
				produce((gg,rf))
			end
		end
		shuffle!(r, indices)
	end
end


function getSequentialRFinite(numTP::Int64,gradientOracle,restoreFunc)
	indices = [1:numTP;]
	for i in indices
		let j=i
			gg=(x)-> gradientOracle(x,j)
			rf=(cs)-> restoreFunc(cs,j)
			# println(j)
			produce((gg,rf))
		end
	end
end

function getSequentialFinite(numTP::Int64,gradientOracle)
	indices = [1:numTP;]
	for i in indices
		let j=i
			gg=(x)-> gradientOracle(x,j)
			produce(gg)
		end
	end
end

function getRandom(numTP::Int64,gradientOracle)
    while true
		i = rand(1:numTP)
		let j=i
			gg=(x)-> gradientOracle(x,j)
			produce(gg)
		end
	end
end

function getSampleFunctionAt(j::Int64, gradientOracle)
	(x)-> gradientOracle(x,j)
end
