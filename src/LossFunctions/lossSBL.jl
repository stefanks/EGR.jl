function SBL_get_f_g(featuresTP::SparseMatrixCSC{Float64,Int64}, labels::MinusPlusOneVector, W::Matrix{Float64}, index::Int64)
	X = featuresTP[:,index]
	Y = labels[index]
	ym=Y*(W'*X)[1]
	(log(1 + exp(-ym)), X*(-Y / (1 + exp(ym))))
end

function SBL_get_f_g(features::SparseMatrixCSC{Float64,Int64}, labels::MinusPlusOneVector, W::Matrix{Float64})
	ym=labels.field.*(features*W)
	mean(log(1 + exp(-ym)))
end

function SBL_for_output(features::SparseMatrixCSC{Float64,Int64}, labels::MinusPlusOneVector, W::Matrix{Float64})
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