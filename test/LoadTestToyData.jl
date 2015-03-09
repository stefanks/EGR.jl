function LoadTestToyData(Oracles)
	
	features = 
	[-1.0  1.0
	-1.0  -1.0
	-1.0  -2.0
	-1.0  -3.0
	1.0  -1.0
	-2.0  -2.0
	1.0   1.0
	-2.0  -3.0
	-0.9  -0.9
	-1.1  -2.1
	-0.8  -0.8
	-1.2  -2.2
	-0.7  -0.7
	-1.3  -2.3
	-0.6  -0.6
	-1.4  -2.4]

	labels = [1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0]

	normalizeFeatures(features, size(features)[2])

	(classLabels, numClasses) = createClassLabels(labels)
	
	(trf, trl, trl2, numTrainingPoints, tef, tel, tel2) = trainTestRandomSeparate(features, MinusPlusOneVector(labels, Set([1.0])), classLabels)

	L2regs=[
	false,
	true
	]
	for L2reg in L2regs
		
		
		(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName) = createBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg, 0, "TestToy")
		
		push!(Oracles, (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, (t)-> Problem(L2reg, thisDataName, LossFunctionString, (w)->gradientOracle(w), numTrainingPoints, t)))
		
		(gradientOracle2, numVars2, numTrainingPoints2, restoreGradient2, csDataType2, LossFunctionString2, myOutputter2, L2reg2, thisDataName2) = createMLOracles(trf, trl2, numTrainingPoints, numClasses, tef, tel2, L2reg, 0, "TestToy") 
		
		push!(Oracles,(gradientOracle2, numVars2, numTrainingPoints2, restoreGradient2, csDataType2, LossFunctionString2, myOutputter2, L2reg2, thisDataName2,  (t)-> Problem(L2reg2, thisDataName2, LossFunctionString2, (w)->gradientOracle2(w), numTrainingPoints2, t)))
		
		
	end
end

LoadTestToyData(Oracles)