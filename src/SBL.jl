function SBL_get_f_g(features::Vector{SparseMatrixCSC{ Bool,Int64}}, labels::MinusPlusOneVector, W::Matrix{Float64}, index::Int64)
	X = features[index]
	Y = labels[index]
	ym=Y*(W'*X)[1]
	# println(typeof(X*(-Y / (1 + exp(ym)))))
# 	println(X*(-Y / (1 + exp(ym))))
# 	println(typeof(vec(X*(-Y / (1 + exp(ym))))))
# 	println(vec(X*(-Y / (1 + exp(ym)))))
	(log(1 + exp(-ym)), X*(-Y / (1 + exp(ym))), ym)
end

function SBL_restore_gradient(features::Vector{SparseMatrixCSC{ Bool,Int64}}, labels::MinusPlusOneVector, ym::Float64, index::Int64)
	X = features[index]
	Y = labels[index]
	vec(X*(-Y / (1 + exp(ym))))
end

function SBL_get_f_g(features::Vector{SparseMatrixCSC{ Bool,Int64}}, labels::MinusPlusOneVector, W::Matrix{Float64})
	ym=zeros(length(labels))
	for i in 1:length(labels)
		ym[i] = labels[i]*(W'*features[i])[1]
	end
	(mean(log(1 + exp(-ym))) ,features'*(-labels.field ./ (1 + exp(ym)))/size(features)[1])
end

# Returns f, percent correctly classified, false positives, false negatives
function SBL_for_output(features::Vector{SparseMatrixCSC{ Bool,Int64}},labels::MinusPlusOneVector,W::Matrix{Float64})
	ym=zeros(length(labels))
	@inbounds @simd for i in 1:length(labels)
		# println(features[i])
		# println(W)
		# println(size(features[i]))
		# println(size(W))
		# println(W*features[i])
		# println((W*features[i])[1])
		# println(labels[i])
		# println(size(W))
		# 	    println(size(features[i]))
		# println(W)
		# println(features[i])
		# println(W'*features[i])
		# println(W*features[i])
		# println(W*features[i]')
		# println(W'*features[i]')
		ym[i] = labels[i]*(W'*features[i])[1]
	end
	(pcc, fp, fn) = (0,0,0)
	for i in 1:size(features)[1]
		if ym[i]<0
			if labels.field[i]<0 
				fp += 1
			elseif labels.field[i]>0 
				fn += 1
			end
		elseif ym[i]>0
			pcc += 1
		end
	end
	(mean(log(1 + exp(-ym))), pcc / size(features)[1], fp/(size(features)[1] - labels.numPlus), fn/labels.numPlus )
end