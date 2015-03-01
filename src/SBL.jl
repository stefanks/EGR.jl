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

function SBL_get_f_g(features::SparseMatrixCSC{Bool,Int64}, labels::MinusPlusOneVector, W::Matrix{Float64})
	ym=labels.field.*(features*W)
	(mean(log(1 + exp(-ym))) ,features'*(-labels.field ./ (1 + exp(ym)))/size(features)[1])
end

# Returns f, percent correctly classified, false positives, false negatives
function SBL_for_output(features::SparseMatrixCSC{Bool,Int64},labels::MinusPlusOneVector,W::Matrix{Float64})
	ym=labels.field.*(features*W)
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