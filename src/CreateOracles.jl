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


function createOracles(features,labels,numDatapoints,numFeatures, setOfOnes; L2reg=false, outputLevel=0)

	# println("Starting separation into train and test sets...")
	(trf,trl,numTrainingPoints, tef, tel) = trainTestRandomSeparate(features,labels)
	# println("Finished")
	trl=MinusPlusOneVector(trl,setOfOnes)
	outputLevel > 0  && println("Fraction of ones in training set: $(trl.numPlus/length(trl))")
	tel=MinusPlusOneVector(tel,setOfOnes)
	outputLevel > 0  && println("Fraction of ones in testing  set: $(tel.numPlus/length(tel))")

	# println("Defining functions...")
	gradientOracle(W,indices) = get_f_g_cs(trf, trl,W,indices)
	gradientOracle(W) = get_f_g_cs(trf, trl,W)
	testFunction(W) = get_f_pcc(tef, tel,W)
		
	function outputsFunction(W)
		ye = testFunction(W)
		yo = gradientOracle(W)
	   	(@sprintf("% .3e % .3e % .3e",ye[1], ye[2], yo[1]), [ye[1], ye[2], yo[1]])
	 end
		
	restoreGradient(cs,indices) = get_g_from_cs(trf, trl,cs,indices)
	# println("Finished")
	#
	# println("Adding regularizer...")
	if L2reg
		mygradientOracle(a) = L2regGradient(gradientOracle, 1e-3,a)
		mygradientOracle(a,b) = L2regGradient(gradientOracle, 1e-3,a,b)
		myrestoreGradient(a,b) = L2RestoreGradient(restoreGradient, 1e-3,a,b)
	else
		mygradientOracle=gradientOracle
		myrestoreGradient=restoreGradient
	end
	# println("Finished")

	numVars = numFeatures
	(mygradientOracle,numTrainingPoints,numVars,outputsFunction,myrestoreGradient)
end