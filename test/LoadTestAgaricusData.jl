function LoadTestAgaricusData(Oracles)

	(features, labels) = readData("data/TestAgaricus/TestAgaricus", (8124,126), 0)
	
	(classLabels, numClasses) = createClassLabels(labels)

	(trf, trl, trl2, numTrainingPoints, tef, tel, tel2) = trainTestRandomSeparate(features, MinusPlusOneVector(labels, Set([1.0])), classLabels)

	L2regs=[
	false,
	true
	]
	
	for L2reg in L2regs
		(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName) = createBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg, 0,"TestAgaricus")
		push!(Oracles, (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, (t)-> Problem(L2reg, thisDataName, LossFunctionString, (w)->gradientOracle(w), numTrainingPoints, t),numVars))
		(gradientOracle2, numVars2, numTrainingPoints2, restoreGradient2, csDataType2, LossFunctionString2, myOutputter2, L2reg2, thisDataName2) = createMLOracles(trf, trl2, numTrainingPoints, numClasses, tef, tel2, L2reg, 0, "TestAgaricus") 
		push!(Oracles,(gradientOracle2, numVars2, numTrainingPoints2, restoreGradient2, csDataType2, LossFunctionString2, myOutputter2, L2reg2, thisDataName2,  (t)-> Problem(L2reg2, thisDataName2, LossFunctionString2, (w)->gradientOracle2(w), numTrainingPoints2, t),numVars))
	end
end


LoadTestAgaricusData(Oracles)