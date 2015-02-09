
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




fileNames = ("/Users/stepa/OneDrive/Data/Toy/Toy","/Users/stepa/OneDrive/Data/Classify_Convex/Classify_Convex","/Users/stepa/OneDrive/Data/BreakMe/BreakMe","/Users/stepa/OneDrive/Data/MNIST/MNIST", "/Users/stepa/OneDrive/Data/alphaGood/alphaGood")


fileNames = ("/Users/stepa/OneDrive/Data/agaricus/agaricus",)


for fileName in fileNames
	println()
	println(fileName)
	tic()
	(n,minfeatureInd,maxfeatureInd,numTotal,minfeature,maxfeature) = getStats(fileName)
	toc()
	println("Number of datapoints = $n")
	println("minfeatureInd   = $minfeatureInd")
	println("maxfeatureInd   = $maxfeatureInd")
	println("number of features   = $(maxfeatureInd-minfeatureInd+1)")
	println("numTotal   = $(numTotal)")
	println("sparsity   = $(numTotal/(n*(maxfeatureInd-minfeatureInd+1)))")
	println("minfeature   = $minfeature")
	println("maxfeature   = $maxfeature")
end