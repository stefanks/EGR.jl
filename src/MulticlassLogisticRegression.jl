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
	(-log(aDb[class]),vec(g),aDb)
end

function ML_restore_gradient(featuresTP::Matrix{Float64}, labels::Vector{Int64}, aDb::Matrix{Float64}, index::Int64)
	numFeatures = size(featuresTP)[1]
	numClasses = size(aDb)[2]
	class=labels[index]
	x = featuresTP[:,index]
	g=x*aDb
	g[:,class]-=x
	vec(g)
end

function ML_get_f_g(featuresTP::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64})
	numFeatures = size(featuresTP)[1]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	(g,f) = @parallel ((a,b)->(a[1]+b[1], a[2]+b[2])) for k in 1:length(labels)
		class=labels[k]
		x= featuresTP[:,k]
		a=exp(x'*W)
		aDb=a/sum(a)
		myAdd = x*aDb
		myAdd[:,class]-=x
		(myAdd, log(aDb[class]))
	end
	(-f/length(labels),vec(g)/length(labels))
end

# Returns f, percent correctly classified
function ML_for_output(featuresTP::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64})
	numFeatures = size(featuresTP)[1]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses))
	(pcc,f) = @parallel ((a,b)->(a[1]+b[1], a[2]+b[2])) for k in 1:length(labels)
		class=labels[k]
		x= featuresTP[:,k] 
		a=exp(x'*W) 
		aDb=a/sum(a) 
		(v,chosenclass) = findmax(a);
		(chosenclass == class ? 1 : 0 , log(aDb[class]))
	end
	(-f/length(labels),pcc/length(labels))
end