function BL_get_f_g(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64},index::Int64)
	X = features[index,:];
	Y = labels[index];
	margin = X*W;
	ym=Y*margin
	f=log(1 + exp(-ym))
	# TODO: CHECK IF THIS IS SLOW, MIGHT BE GOOD TO GET RID OF TRANSPOSE!!!
	# TODO: check if better to store the X in columns vs rows!!!!!! 
	g=X'*(-Y ./ (1 + exp(ym)))
	(f ,g, margin)
end


function BL_get_f_g(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64},indices)
	# TODO: CHECK IF THIS IS SLOW, MIGHT BE GOOD TO DO COPY!!!
	#       ONLY FOR MEDIUM BATCH SIZES!
	X = features[indices,:];
	Y = labels[indices];
	examples = size(X)[1];
	margins = X*W;
	ym=Y.*margins
	f=sum( log(1 + exp(-ym)) ) / examples 
	# TODO: CHECK IF THIS IS SLOW, MIGHT BE GOOD TO GET RID OF TRANSPOSE!!!
	g=X'*(-Y ./ (1 + exp(ym))) / examples 
	(f ,g, margins)
end

function BL_restore_gradient(features::Matrix{Float64},labels::MinusPlusOneVector,margins,indices)
	# TODO: CHECK IF THIS IS SLOW, MIGHT BE GOOD TO DO COPY!!!
	#       ONLY FOR MEDIUM BATCH SIZES!
	X = features[indices,:];
	Y = labels[indices];
	examples = size(X)[1];
	ym=Y.*margins
	# f=sum( log(1 + exp(-ym)) ) / examples
	# TODO: CHECK IF THIS IS SLOW, MIGHT BE GOOD TO GET RID OF TRANSPOSE!!!
	g=X'*(-Y ./ (1 + exp(ym))) / examples 
end

function BL_get_f_g(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64})
	X = features;
	Y = labels.field;
	examples = size(X)[1];
	margins = X*W;
	ym=Y.*margins
	f=sum( log(1 + exp(-ym)) ) / examples 
	# println("f is ")
	# println(f)
	# println("f is of type ")
	# println(typeof(f))
	# TODO: CHECK IF THIS IS SLOW!!!
	g=X'*(-Y ./ (1 + exp(ym))) / examples 
	(f ,g, margins)
end

# Returns f, percent correctly classified, false positives, false negatives
function BL_for_output(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64})
	X = features;
	Y = labels.field;
	examples = size(X)[1];
	# println("size(W) =$(size(W))")
	# println("size(X) =$(size(X))")
	margins = X*W;
	# println("size(margins) =$(size(margins))")
	ym=Y.*margins
	pcc=0
	fp=0
	fn=0
	for i in 1 : examples
		if ym[i]<0
			if Y[i]<0 
				fp += 1
			elseif Y[i]>0 
				fn += 1
			end
		elseif ym[i]>0
			pcc += 1
		end
	end
	(sum( log(1 + exp(-ym)) ) / examples  , pcc / examples, fp/(examples - labels.numPlus), fn/labels.numPlus )
end
