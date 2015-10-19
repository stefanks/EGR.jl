function ML_get_f_g(featuresTP::Matrix{Float64}, labels::Vector{Float64}, W::Matrix{Float64}, index::Int64)
	numFeatures = size(featuresTP)[1]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	class=labels[index]
	x = featuresTP[:,index]
	a=exp(x'*W) 
	aDb=a/sum(a) 
	g=x*aDb
	g[:,round(Int,class)]-=x
	(-log(aDb[round(Int,class)]),reshape(g, (numFeatures*numClasses,1)),aDb)
end

function ML_restore_gradient(featuresTP::Matrix{Float64}, labels::Vector{Float64}, aDb, index::Int64)
	numFeatures = size(featuresTP)[1]
	numClasses = 129
	class=labels[index]
	x = featuresTP[:,index]
	g=x*aDb
	g[:,class]-=x
	reshape(g, (numFeatures*numClasses,1))
end

function ML_get_f(features::Matrix{Float64}, labels::Vector{Float64}, W::Matrix{Float64})
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	f=0
	@inbounds @simd for k=1:length(labels)
		class=labels[k]
		x=features[k,:]
		a=exp(x*W)
		aDb=a/sum(a)
		f+=log(aDb[round(Int,class)])
	end
	(-f/length(labels))
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
		if chosenclass == class
			pcc+=1
		end
		aDb=a/sum(a)
		f+=log(aDb[round(Int,class)])
	end
	(-f/length(labels),pcc/length(labels))
end