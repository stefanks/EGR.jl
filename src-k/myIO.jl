module  myIO

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

end