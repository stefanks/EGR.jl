function trainTestRandomSeparate(features,labels)
	srand(1)
	shuffledIndices = shuffle([1 : size(labels)[1]])
	numTrainingPoints = div(size(labels)[1]*3,4)
	(copy(features[shuffledIndices[1:numTrainingPoints      ],:]),
	copy(labels  [shuffledIndices[1:numTrainingPoints      ]  ]),
	numTrainingPoints,
	copy(features[shuffledIndices[(numTrainingPoints+1):end],:]),
	copy(labels[  shuffledIndices[(numTrainingPoints+1):end]  ]))
end


function createOracles(features,labels,numFeatures,numDatapoints; L2reg=false,outputLevel=0)

	# println("Starting separation into train and test sets...")
	(trf,trl,numTrainingPoints, tef, tel) = trainTestRandomSeparate(features,labels)
	# println("Finished")
	trl=MinusPlusOneVector(trl,Set([1.0]))
	tel=MinusPlusOneVector(tel,Set([1.0]))

	# println("Defining functions...")
	gradientOracle(W,indices) = get_f_g_cs(trf, trl,W,indices)
	gradientOracle(W) = get_f_g_cs(trf, trl,W)
	testFunction(W) = get_f_pcc(tef, tel,W)
		
	outputsFunction(W) = (testFunction(W), gradientOracle(W)[1])
		
	restoreGradient(cs,indices) = get_g_from_cs(trf, trl,cs,indices)
	# println("Finished")
	#
	# println("Adding regularizer...")
	if L2reg
		gradientOracle(a,b) = L2regGradient(gradientOracle, 1e-3, a,b)
	end
	# println("Finished")

	(gradientOracle,numTrainingPoints,numFeatures,outputsFunction,restoreGradient)
end