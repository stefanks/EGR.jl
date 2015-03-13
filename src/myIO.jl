function readData(fname::String, shape, minFeatureInd::Integer)
	features = zeros(shape)
	labels = Float64[]
	fi = open(fname, "r")
	cnt = 1
	for line in eachline(fi)
		line = split(line, " ")
		push!(labels, float64(line[1]))
		line = line[2:end]
		for itm in line
			itm = split(itm, ":")
			features[cnt, int(itm[1]) + 1-minFeatureInd] = float64(chomp(itm[2]))
		end
		cnt += 1
	end
	close(fi)
	(features, labels)
end

function readDataSparse(fname::String, shape, minFeatureInd::Integer)
	A = Int64[]
	B = Int64[]
	C = Float64[]
	labels = Float64[]
	# featuresVec =  SparseMatrixCSC{Float64,Int64}[]
	# featuresVec2 =  SparseMatrixCSC{Float64,Int64}[]
	fi = open(fname, "r")
	cnt = 1
	
	for line in eachline(fi)
		# A1 = Int64[]
		# B1= Int64[]
		# C1 = Float64[]
		line = split(line, " ")
		push!(labels, float64(line[1]))
		line = line[2:end]
		for itm in line
			itm = split(itm, ":")
			push!(A, cnt)
			push!(B, int(itm[1]) + 1-minFeatureInd)
			push!(C, float64(chomp(itm[2])))
			
			# push!(A1, int(itm[1]) + 1-minFeatureInd)
			# push!(B1, 1)
			# push!(C1, float64(chomp(itm[2])))
			
		
		end
		
		# push!(featuresVec, sparse(A1, B1, C1,shape[2],1))
		# push!(featuresVec2, sparse( B1,A1, C1,1,shape[2]))
		cnt += 1
	end
	close(fi)
	
	features = sparse(A,B,C)
	
	# (features, featuresVec, featuresVec2,  labels)
	(features, labels)
end

function writeBin(fname::String, features, labels)
	fi = open(fname, "w")
	write(fi, features)
	write(fi, labels)
	close(fi)
end

function readBin(fname::String,numDatapoints::Integer,numVars::Integer)
	fi = open(fname, "r")
	features = read(fi, Float64, (numDatapoints,numVars))
	labels = read(fi, Float64, (numDatapoints,))
	close(fi)
	(features,labels)
end

function getStats(fname::String)
	fi = open(fname, "r")
	n = 0
	numTotal=0
	minfeatureInd=typemax(Int)
	maxfeatureInd=typemin(Int)
	minfeature=typemax(Int)
	maxfeature=typemin(Int)
	mySetOfClasses = Set()
	for line in eachline(fi)
		n += 1
		line = split(line, " ")
		push!(mySetOfClasses, line[1])
		line = line[2:end]
		for itm in line
			itm = split(itm, ":")
			minfeatureInd = min(minfeatureInd,int64(itm[1]))
			maxfeatureInd = max(maxfeatureInd,int64(itm[1]))
			minfeature = min(minfeature,float64(chomp(itm[2])))
			maxfeature = max(maxfeature,float64(chomp(itm[2])))
			numTotal+=1
		end
	end
	
	if numTotal!=n*(maxfeatureInd-minfeatureInd+1)
		minfeature = min(minfeature,0)
		maxfeature = max(maxfeature,0)
	end
	
	close(fi)
	
	(n,minfeatureInd,maxfeatureInd-minfeatureInd+1,numTotal,minfeature,maxfeature, length(mySetOfClasses))
end


function getStatsHIGGSSUSY(fname::String)
	fi = open(fname, "r")
	n = 0
	numTotal=0
	minfeature=typemax(Int)
	maxfeature=typemin(Int)
	mySetOfClasses = Set()
	for line in eachline(fi)
		n += 1
		line = split(line, ",")
		push!(mySetOfClasses, line[1])
		line = line[2:end]
		for itm in line
			minfeature = min(minfeature,float64(chomp(itm)))
			maxfeature = max(maxfeature,float64(chomp(itm)))
			numTotal+=1
		end
	end
	close(fi)
	(n,numTotal,minfeature,maxfeature, length(mySetOfClasses))
end


function readDataHIGGSSUSY(fname::String, shape)
	features = zeros(shape)
	labels = Float64[]
	fi = open(fname, "r")
	cnt = 1
	for line in eachline(fi)
		line = split(line, ",")
		push!(labels, float64(line[1]))
		line = line[2:end]
		for i in 1:length(line)
			features[cnt, i] = float64(chomp(line[i]))
		end
		cnt += 1
	end
	close(fi)
	(features, labels)
end

function getStatsIRIS(fname::String)
	fi = open(fname, "r")
	n = 0
	numTotal=0
	minfeature=typemax(Int)
	maxfeature=typemin(Int)
	mySetOfClasses = Set()
	for line in eachline(fi)
		n += 1
		line = split(line, ",")
		push!(mySetOfClasses, chomp(line[end]))
		line = line[1:end-1]
		for itm in line
			minfeature = min(minfeature,float64(chomp(itm)))
			maxfeature = max(maxfeature,float64(chomp(itm)))
			numTotal+=1
		end
	end
	close(fi)
	println(mySetOfClasses)
	(n,numTotal,minfeature,maxfeature, length(mySetOfClasses))
end

function readDataIRIS(fname::String, shape)
	features = zeros(shape)
	labels = String[]
	fi = open(fname, "r")
	cnt = 1
	for line in eachline(fi)
		line = split(line, ",")
		push!(labels, chomp(line[end]))
		line = line[1:end-1]
		for i in 1:length(line)
			features[cnt, i] = float64(chomp(line[i]))
		end
		cnt += 1
	end
	close(fi)
	(features, labels)
end