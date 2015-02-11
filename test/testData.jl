
fileNames = ("data/agaricus/agaricus",)

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