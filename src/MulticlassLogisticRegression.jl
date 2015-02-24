function ML_get_f_g(features::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64}, index::Int64)
	# X = featuresTP[:,index]
	# Y = labels[index]
	# ym=Y*dot(X,W)
	# (log(1 + exp(-ym)), X*(-Y / (1 + exp(ym))), ym)
	

	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses));

	f=0;

	class=labels[index]
	# get the feature row-vector
	x = features[index,:]
        
	a=exp(x*W);  #1 by numClasses
	b=sum(a);  
		
	aDb=a/b; #1 by numClasses
	g=x'*aDb;
        
	g[:,class]=g[:,class]-x';
        
	f-=log(a[class]/b);

	(v,chosenclass) = findmax(a);
	
	g=vec(g);
	(f,g,g)
	
	
end

function ML_restore_gradient(featuresTP::Matrix{Float64}, labels::Vector{Int64}, cs::Vector{Float64}, index::Int64)
	# X = featuresTP[:,index]
	# Y = labels[index]
	# X*(-Y / (1 + exp(ym)))
	cs
end

function ML_get_f_g(features::Matrix{Float64}, labels::Vector{Int64}, W::Vector{Float64})
	# ym=labels.field.*(features*W)
	# (mean(log(1 + exp(-ym))) ,features'*(-labels.field ./ (1 + exp(ym)))/size(features)[1])
	numFeatures = size(features)[2]
		numClasses = div(length(W),numFeatures)
		W=reshape(W,(numFeatures,numClasses));
		g=zeros(size(W));

		f=0;
	
		for k in 1:length(labels)
		
			class=labels[k]
			# get the feature row-vector
			x= features[k,:] #1 by numFeatures
        
			a=exp(x*W);  #1 by numClasses
			b=sum(a);  
		
			aDb=a/b; #1 by numClasses
			g+=x'*aDb;
        
			g[:,class]=g[:,class]-x';
        
			f-=log(a[class]/b);

			(v,chosenclass) = findmax(a);
        
		end

		f=f/length(labels);
		g=vec(g)/length(labels);
		(f,g,g)
end

# Returns f, percent correctly classified
function ML_for_output(features::Matrix{Float64},labels::Vector{Int64},W::Vector{Float64})
	# ym=labels.field.*(features*W)
	# (pcc, fp, fn) = (0,0,0)
	# for i in 1:size(features)[1]
	# 	if ym[i]<0
	# 		if labels.field[i]<0
	# 			fp += 1
	# 		elseif labels.field[i]>0
	# 			fn += 1
	# 		end
	# 	elseif ym[i]>0
	# 		pcc += 1
	# 	end
	# end
	# (mean(log(1 + exp(-ym))), pcc / size(features)[1], fp/(size(features)[1] - labels.numPlus), fn/labels.numPlus )	
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses));

	f=0;
	pcc=0
	
	for k in 1:length(labels)
		
		class=labels[k]
		# get the feature row-vector
		x= features[k,:] #1 by numFeatures
        
		a=exp(x*W);  #1 by numClasses
		b=sum(a);  

		f-=log(a[class]/b);

		(v,chosenclass) = findmax(a);
        
		if chosenclass == class
			pcc+= 1;
		end
		
	end

	f=f/length(labels);
	pcc = pcc/length(labels)
	(f,pcc)
	
end