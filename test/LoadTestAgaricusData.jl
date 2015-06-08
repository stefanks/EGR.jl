function LoadTestAgaricusData(Oracles)

	(features, labels) = readData("data/TestAgaricus/TestAgaricus", (8124,126), 0)
	
	(classLabels, numClasses) = createClassLabels(labels)

	(trf, trl, trl2, numTrainingPoints, tef, tel, tel2) = trainTestRandomSeparate(features, MinusPlusOneVector(labels, Set([1.0])), classLabels)

	L2regs=[
	false,
	true
	]
	
	for L2reg in L2regs
		(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg) = createBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg; outputLevel = 0) 
		
		push!(Oracles, (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg,  "TestAgaricus", (t)-> Problem(L2reg, "TestAgaricus", LossFunctionString, (w)->gradientOracle(w), numTrainingPoints, t,(j)->getSampleFunctionAt(j,gradientOracle,restoreGradient))))
		
		
		(gradientOracle2, numVars2, numTrainingPoints2, restoreGradient2, csDataType2, LossFunctionString2, myOutputter2, L2reg2) = createMLOracles(trf, trl2, numTrainingPoints, numClasses, tef, tel2, L2reg; outputLevel = 0) 
		
		push!(Oracles,(gradientOracle2, numVars2, numTrainingPoints2, restoreGradient2, csDataType2, LossFunctionString2, myOutputter2, L2reg2, "TestAgaricus", (t)-> Problem(L2reg2, "TestAgaricus", LossFunctionString2, (w)->gradientOracle2(w), numTrainingPoints2, t,(j)->getSampleFunctionAt(j,gradientOracle2,restoreGradient2))))
	end
end


LoadTestAgaricusData(Oracles)