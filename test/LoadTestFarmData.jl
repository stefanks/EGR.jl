function LoadTestFarmData(Oracles)

	(features, labels) = readDataSparse("data/TestFarm/TestFarm", (4143,54877), 1)
	
	(classLabels, numClasses) = createClassLabels(labels)
	
	(trf, trl, trl2, numTrainingPoints, tef, tel, tel2) = trainTestRandomSeparate(features, MinusPlusOneVector(labels, Set([1.0])), classLabels)

	L2regs=[
	false,
	true
	]
	for L2reg in L2regs
		
		
		(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg) = createSBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg; outputLevel = 0) 
		
		push!(Oracles, (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, "TestSparse", (t)-> Problem(L2reg, "TestSparse", LossFunctionString, (w)->gradientOracle(w), numTrainingPoints, t), (numVars, 1)))
		
	end
end

LoadTestFarmData(Oracles)