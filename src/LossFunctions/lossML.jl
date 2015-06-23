function ML_get_f_g(featuresTP::Matrix{Float64}, labels::Vector{Float64}, W::Matrix{Float64}, index::Int64)
	numFeatures = size(featuresTP)[1]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	class=labels[index]
	x = featuresTP[:,index]
	a=exp(x'*W) 
	aDb=a/sum(a) 
	g=x*aDb
	g[:,class]-=x
	# println("aDb = ")
	# println(aDb)
	(-log(aDb[class]),reshape(g, (numFeatures*numClasses,1)))
end


function ML_get_f_g(features::Matrix{Float64}, labels::Vector{Float64}, W::Matrix{Float64})
	# println(features)
	# println(labels)
	# println(W)
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	# println("numFeatures $numFeatures")
	# println("numClasses $numClasses")
	W=reshape(W,(numFeatures,numClasses))
	g=zeros(size(W))
	f=0
	 @inbounds @simd for k=1:length(labels)
		class=labels[k]
		x=features[k,:]
		a=exp(x*W)
		aDb=a/sum(a)
		for j in 1:size(g)[2]
			for i in 1:size(g)[1]
				g[i,j] =g[i,j]+ x[i]*aDb[j]
			end
		end
		# println(g)
		g[:,class]=g[:,class]-x'
		f+=log(aDb[class])
	end
	(-f/length(labels), reshape(g, (numFeatures*numClasses,1))/length(labels))
end

# Returns f, percent correctly classified
function ML_for_output(features::Matrix{Float64}, labels::Vector{Float64}, W::Matrix{Float64})
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	g=zeros(size(W))
	f=0
	pcc=0
	 @inbounds @simd for k=1:length(labels)
		class=labels[k]
		x=features[k,:]
		a=exp(x*W)
		(v,chosenclass) = findmax(a);
		# println((class,chosenclass))
		if chosenclass == class
			# println("Found good!")
			pcc+=1
		end
		aDb=a/sum(a)
		f+=log(aDb[class])
	end
	(-f/length(labels),pcc/length(labels))
end