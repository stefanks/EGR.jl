function ML_get_f_g(featuresTP::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64}, index::Int64)
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
	(-log(aDb[class]),vec(g),aDb)
end

function ML_restore_gradient(featuresTP::Matrix{Float64}, labels::Vector{Int64}, aDb::Matrix{Float64}, index::Int64)
	# println("IN restoration")
	# println("aDb = ")
	# println(aDb)
	numFeatures = size(featuresTP)[1]
	numClasses = size(aDb)[2]
	class=labels[index]
	x = featuresTP[:,index]
	g=x*aDb
	g[:,class]-=x
	vec(g)
end

function ML_get_f_g(features::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64})
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	g=zeros(size(W));
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
		g[:,class]=g[:,class]-x'
		f+=log(aDb[class])
	end
	(-f/length(labels), vec(g)/length(labels))
end

# Returns f, percent correctly classified
function ML_for_output(features::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64})
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	g=zeros(size(W));
	f=0
	pcc=0
	 @inbounds @simd for k=1:length(labels)
		class=labels[k]
		x=features[k,:]
		a=exp(x*W)
		(v,chosenclass) = findmax(a);
		if chosenclass == class
			pcc+=1
		end
		aDb=a/sum(a)
		f+=log(aDb[class])
	end
	(-f/length(labels),pcc/length(labels))
end