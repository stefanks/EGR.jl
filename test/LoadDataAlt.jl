function LoadDataAlt()
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

	dict = {"trf"=> trf, "trl"=> trl, "trl2"=> trl2, "numTrainingPoints" => numTrainingPoints, "tef" => tef, "tel" => tel, "tel2" => tel2, "name" => "TestToy", "numClasses" => numClasses}

end

FullDict["TestToy"] = LoadDataAlt()