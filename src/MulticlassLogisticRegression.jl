function ML_get_f_g(features::Matrix{Float64},labels::Vector{Int},W::Vector{Float64},index::Int64)
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses));
	g=zeros(size(W));

	f=0;

	class=labels[index]
	# get the feature row-vector
	x = features[index,:]
        
	a=exp(x*W);  #1 by numClasses
	b=sum(a);  
		
	aDb=a/b; #1 by numClasses
	g+=x'*aDb;
        
	g[:,class]=g[:,class]-x';
        
	f-=log(a[class]/b);

	(v,chosenclass) = findmax(a);
        

	g=vec(g);
	(f,g,g)
	
	
end


function ML_get_f_g(features::Matrix{Float64},labels::Vector{Int},W::Vector{Float64},indices)
	numFeatures = size(features)[2]
	numClasses = div(length(W),numFeatures)
	W=reshape(W,(numFeatures,numClasses));
	g=zeros(size(W));

	f=0;

	for k in 1:length(indices)
		h=indices[k]
		# get the label
		class=labels[h]
		# get the feature row-vector
		x = features[h,:]
        
		a=exp(x*W);  #1 by numClasses
		b=sum(a);  
		
		aDb=a/b; #1 by numClasses
		g+=x'*aDb;
        
		g[:,class]=g[:,class]-x';
        
		f-=log(a[class]/b);

		(v,chosenclass) = findmax(a);
        
	end

	f=f/length(indices);
	g=vec(g)/length(indices);
	(f,g,g)
	
	
end

function ML_restore_gradient(features::Matrix{Float64},labels::Vector{Int},cs,indices)
	cs
end

function ML_get_f_g(features::Matrix{Float64},labels::Vector{Int},W::Vector{Float64})
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
function ML_for_output(features::Matrix{Float64},labels::Vector{Int},W::Vector{Float64})
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
