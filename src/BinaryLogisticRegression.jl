
function get_f_g_cs(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64},index::Int64)
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


function get_f_g_cs(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64},indices)
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

function get_g_from_cs(features::Matrix{Float64},labels::MinusPlusOneVector,margins,indices)
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

function get_f_g_cs(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64})
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


function get_f_pcc(features::Matrix{Float64},labels::MinusPlusOneVector,W::Vector{Float64})
	X = features;
	Y = labels.field;
	examples = size(X)[1];
	# println("size(W) =$(size(W))")
	# println("size(X) =$(size(X))")
	margins = X*W;
	# println("size(margins) =$(size(margins))")
	ym=Y.*margins
	f=sum( log(1 + exp(-ym)) ) / examples 
	(f , count(c -> c > 0, ym) / examples  )
end
