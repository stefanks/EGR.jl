function trainTestRandomSeparate(features,labels)
	srand(1)
	shuffledIndices = shuffle([1 : size(labels)[1];])
	numTrainingPoints = div(size(labels)[1]*3,4)
	(copy(features[shuffledIndices[1:numTrainingPoints      ],:]),
	copy(labels  [shuffledIndices[1:numTrainingPoints      ]  ]),
	numTrainingPoints,
	copy(features[shuffledIndices[(numTrainingPoints+1):end],:]),
	copy(labels[  shuffledIndices[(numTrainingPoints+1):end]  ]))
end


function createBLOracles(features,labels, setOfOnes, L2reg::Bool, outputLevel)
	numDatapoints = length(labels)
	numFeatures = size(features)[2] 
	
	outputLevel > 0  && println("Creating oracles")
	(trf,trl,numTrainingPoints, tef, tel) = trainTestRandomSeparate(features,labels)
	trl=MinusPlusOneVector(trl,setOfOnes)
	outputLevel > 0  && println("Fraction of ones in training set: $(trl.numPlus/length(trl))")
	tel=MinusPlusOneVector(tel,setOfOnes)
	outputLevel > 0  && println("Fraction of ones in testing  set: $(tel.numPlus/length(tel))")
	
	trft=trf'
	gradientOracle(W,index) = BL_get_f_g(trft, trl,W,index)
	gradientOracle(W) = BL_get_f_g(trf, trl,W)
	testFunction(W) = BL_for_output(tef, tel,W)
		
	function outputsFunction(W)
		ye = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(@sprintf("% .3e % .3e % .3e % .3e % .3e",ye[1], ye[2], ye[3], ye[4], yo[1]), [ye[1], ye[2], ye[3], ye[4], yo[1]])
	end
		
	restoreGradient(cs,indices) = BL_restore_gradient(trft, trl,cs,indices)
	
	if L2reg
		mygradientOracle(a) = L2regGradient(gradientOracle, 1/numTrainingPoints, a)
		mygradientOracle(a, b) = L2regGradient(gradientOracle, 1/numTrainingPoints, a, b)
		myrestoreGradient(a, b) = L2RestoreGradient(restoreGradient, 1/numTrainingPoints, a, b)
		csDataType = Vector{Float64}
	else
		mygradientOracle=gradientOracle
		myrestoreGradient=restoreGradient
		csDataType = Float64
	end

	numVars = numFeatures
	(mygradientOracle,numTrainingPoints,numVars,outputsFunction,myrestoreGradient,csDataType, "       f         pcc        fp         fn       f-train  ", "BL", 5)
end

function createMLOracles(features,labels, L2reg::Bool, outputLevel)
	
	numDatapoints = length(labels)
	numFeatures = size(features)[2] 
	
	outputLevel > 0  && println("Creating oracles")
	
	classesDict=(Float64 => (Int64, Int64))[]

	currentClass =0
	classLabels = zeros(Int64,numDatapoints )
	for i in 1:numDatapoints
		if haskey(classesDict, labels[i])
			classesDict[labels[i]]=(classesDict[labels[i]][1],classesDict[labels[i]][2]+ 1)
			classLabels[i] = classesDict[labels[i]][1]
		else
			currentClass +=1
			classesDict[labels[i]] = (currentClass,1)
			classLabels[i] = currentClass
		end
	end
	
	outputLevel > 1  && println(classesDict)
	outputLevel > 0  && println("Number of classes is $(length(classesDict))")
	
	(trf,trl,numTrainingPoints, tef, tel) = trainTestRandomSeparate(features,classLabels)
	
	trft=trf'
	gradientOracle(W,index) = ML_get_f_g(trft, trl,W,index)
	gradientOracle(W) = ML_get_f_g(trf, trl,W)
	testFunction(W) = ML_for_output(tef, tel,W)
	
	function outputsFunction(W)
		ye = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(@sprintf("% .3e % .3e % .3e",ye[1], ye[2], yo[1]), [ye[1], ye[2], yo[1]])
	end
	
	restoreGradient(cs,indices) = ML_restore_gradient(trft, trl,cs,indices)
	if L2reg
		mygradientOracle(a) = L2regGradient(gradientOracle, 1/numTrainingPoints, a)
		mygradientOracle(a, b) = L2regGradient(gradientOracle, 1/numTrainingPoints, a, b)
		myrestoreGradient(a, b) = L2RestoreGradient(restoreGradient, 1/numTrainingPoints, a, b)
		csDataType=Vector{Float64}
	else
		mygradientOracle=gradientOracle
		myrestoreGradient=restoreGradient
		csDataType=Matrix{Float64}
	end
	
	numVars = numFeatures*length(classesDict)
	(mygradientOracle, numTrainingPoints, numVars, outputsFunction, myrestoreGradient, csDataType,  "      f         pcc       f-train  ", "ML", 3 )
end