function BL_get_f_g(featuresTP::Matrix{Float64}, labels::MinusPlusOneVector, W::Vector{Float64}, index::Int64)
	X = featuresTP[:,index]
	Y = labels[index]
	ym=Y*dot(X,W)
	(log(1 + exp(-ym)), X*(-Y / (1 + exp(ym))), ym)
end

function BL_restore_gradient(featuresTP::Matrix{Float64}, labels::MinusPlusOneVector, ym::Float64, index::Int64)
	# println("restoring BL")
	X = featuresTP[:,index]
	Y = labels[index]
	X*(-Y / (1 + exp(ym)))
end

function BL_get_f_g(features::Matrix{Float64}, labels::MinusPlusOneVector, W::Vector{Float64})
	ym=labels.field.*(features*W)
	(mean(log(1 + exp(-ym))) ,features'*(-labels.field ./ (1 + exp(ym)))/size(features)[1])
end

# Returns f, pcc, mcc, tp, tn, fp, fn
function BL_for_output(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64})
	ym=labels.field.*(features*W)
	fp, fn = 0,0 
	for i in 1:length(labels)
		if ym[i]<=0
			if labels.field[i]<0 
				fp += 1
			elseif labels.field[i]>0 
				fn += 1
			end
		end
	end
	tp = labels.numPlus - fn
	tn = length(labels) - labels.numPlus - fp
	pcc = (tp+tn)/(tp+tn+fp+fn)
	mcc = (tp*tn - fp*fn)/(sqrt(tp+fp)*sqrt(tp+fn)*sqrt(tn+fp)*sqrt(tn+fn))
	(mean(log(1 + exp(-ym))), pcc, mcc, tp, tn, fp, fn)
end