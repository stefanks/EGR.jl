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
		
		(gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg) = createBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg; outputLevel = 0)
		
		push!(Oracles, (gradientOracle, numVars, numTrainingPoints, csDataType, LossFunctionString, myOutputter, L2reg,  "TestToy", (t)-> Problem(L2reg, "TestToy", LossFunctionString, numTrainingPoints, t,(j)->getSampleFunctionAt(j,gradientOracle))))
		
		(gradientOracle2, numVars2, numTrainingPoints2, csDataType2, LossFunctionString2, myOutputter2, L2reg2) = createMLOracles(trf, trl2, numTrainingPoints, numClasses, tef, tel2, L2reg; outputLevel = 0) 
		
		push!(Oracles,(gradientOracle2, numVars2, numTrainingPoints2, csDataType2, LossFunctionString2, myOutputter2, L2reg2,  "TestToy",  (t)-> Problem(L2reg2, "TestToy", LossFunctionString2,  numTrainingPoints2, t ,(j)->getSampleFunctionAt(j,gradientOracle2))))
		
	end
end

LoadTestToyData(Oracles)