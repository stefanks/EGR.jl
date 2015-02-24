function BL_get_f_g(featuresTP::Matrix{Float64}, labels::MinusPlusOneVector, W::Vector{Float64}, index::Int64)
	X = featuresTP[:,index]
	Y = labels[index]
	ym=Y*dot(X,W)
	(log(1 + exp(-ym)), X*(-Y / (1 + exp(ym))), ym)
end

function BL_restore_gradient(featuresTP::Matrix{Float64}, labels::MinusPlusOneVector, ym::Float64, index::Int64)
	X = featuresTP[:,index]
	Y = labels[index]
	X*(-Y / (1 + exp(ym)))
end

function BL_get_f_g(features::Matrix{Float64}, labels::MinusPlusOneVector, W::Vector{Float64})
	ym=labels.field.*(features*W)
	(mean(log(1 + exp(-ym))) ,features'*(-labels.field ./ (1 + exp(ym)))/size(features)[1])
end

# Returns f, percent correctly classified, false positives, false negatives
function BL_for_output(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64})
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