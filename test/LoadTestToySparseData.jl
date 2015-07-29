function LoadTestSparseData(Oracles)
	
	features = sparse([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4], [0.746453, -0.646761,-0.768557,-1.26793, -2.18751,-0.0529194, -3.98887,-0.30549,  1.10894, 0.111473, 0.639841, 0.337336,  0.348856, 2.40815, 0.573903, -1.27225])

	# featuresTP = sparse([1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], [0.746453, -0.646761,-0.768557,-1.26793, -2.18751,-0.0529194, -3.98887,-0.30549,  1.10894, 0.111473, 0.639841, 0.337336,  0.348856, 2.40815, 0.573903, -1.27225])

	# featuresVec = SparseMatrixCSC{Float64,Int64}[]
	#
	# push!(featuresVec, sparsevec([1],[0.746453]))
	# push!(featuresVec, sparsevec([2],[-0.646761]))
	# push!(featuresVec, sparsevec([3],[-0.768557]))
	# push!(featuresVec, sparsevec([4],[-1.26793]))
	# push!(featuresVec, sparsevec([1],[ -2.18751]))
	# push!(featuresVec, sparsevec([2],[-0.0529194]))
	# push!(featuresVec, sparsevec([3],[-3.98887]))
	# push!(featuresVec, sparsevec([4],[-0.30549]))
	# push!(featuresVec, sparsevec([1],[ 1.10894]))
	# push!(featuresVec, sparsevec([2],[0.111473]))
	# push!(featuresVec, sparsevec([3],[0.639841]))
	# push!(featuresVec, sparsevec([4],[0.337336]))
	# push!(featuresVec, sparsevec([1],[ 0.348856]))
	# push!(featuresVec, sparsevec([2],[2.40815]))
	# push!(featuresVec, sparsevec([3],[0.573903]))
	# push!(featuresVec, sparsevec([4],[ -1.27225]))

	labels = [1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0]
	
	(classLabels, numClasses) = createClassLabels(labels)
	
	(trf, trl, trl2, numTrainingPoints, tef, tel, tel2) = trainTestRandomSeparate(features, MinusPlusOneVector(labels, Set([1.0])), classLabels)

	L2regs=[
	false,
	true
	]
	for L2reg in L2regs
		
		
		(gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg) = createSBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg; outputLevel = 0) 
		
		push!(Oracles, (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg, "TestSparse", (t)-> Problem(L2reg, "TestSparse", LossFunctionString,  numTrainingPoints, t,(j)->getSampleFunctionAt(j,gradientOracle))))
		
		
	end
end

LoadTestSparseData(Oracles)