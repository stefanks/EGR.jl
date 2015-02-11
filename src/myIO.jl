function readData(fname::String, shape, minFeatureInd::Integer)
	features = zeros(shape)
	labels = Float64[]
	fi = open(fname, "r")
	cnt = 1
	for line in eachline(fi)
		line = split(line, " ")
		push!(labels, float(line[1]))
		line = line[2:end]
		for itm in line
			itm = split(itm, ":")
			features[cnt, int(itm[1]) + 1-minFeatureInd] = float(chomp(itm[2]))
		end
		cnt += 1
	end
	close(fi)
	(features, labels)
end

function readWrite(datasetHT::Dict)
	(features, labels) = readData(datasetHT["path"]*datasetHT["filename"], (int(datasetHT["nDatapoints"]),int(datasetHT["nFeatures"])), int(datasetHT["minFeatureInd"]))
	fi = open(datasetHT["path"]*datasetHT["name"]*".bin", "w")
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
	for line in eachline(fi)
		n += 1
		line = split(line, " ")
		line = line[2:end]
		for itm in line
			itm = split(itm, ":")
			minfeatureInd = min(minfeatureInd,int(itm[1]))
			maxfeatureInd = max(maxfeatureInd,int(itm[1]))
			minfeature = min(minfeature,float(chomp(itm[2])))
			maxfeature = max(maxfeature,float(chomp(itm[2])))
			numTotal+=1
		end
	end
	
	if numTotal!=n*(maxfeatureInd-minfeatureInd+1)
		minfeature = min(minfeature,0)
		maxfeature = max(maxfeature,0)
	end
	
	close(fi)
	
	return (n,minfeatureInd,maxfeatureInd,numTotal,minfeature,maxfeature)
end

