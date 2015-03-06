function createClassLabels(labels; outputLevel = 0)

	numDatapoints = length(labels)

	outputLevel > 0  && println("Creating class labels")

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
	println(classesDict)
	outputLevel > 1  && println(classesDict)
	outputLevel > 0  && println("Number of classes is $(length(classesDict))")
	
	(classLabels, length(classesDict))
end

# Normalize to [-1,1]. This affects sparsity!
function normalizeFeatures(features, numFeatures)
	for j in 1:numFeatures
		thismax = maximum(features[:,j])
		thismin = minimum(features[:,j])
		features[:,j] =(2* features[:,j]-thismax-thismin)/(thismax-thismin)
	end
end

function trainTestRandomSeparate(features,labels::MinusPlusOneVector, labels2::Vector{Int64})
	srand(1)
	shuffledIndices = shuffle([1 : length(labels)])
	numTrainingPoints = div(length(labels)*3,4)
	println("numTrainingPoints = $numTrainingPoints")
	println("numTestingPoints = $(length(labels)-numTrainingPoints)")
	(copy(features[shuffledIndices[1:numTrainingPoints      ],:]),
	 MinusPlusOneVector(labels  [shuffledIndices[1:numTrainingPoints      ]  ]),
	copy(labels2  [shuffledIndices[1:numTrainingPoints      ]  ]),
	 numTrainingPoints,
	 copy(features[shuffledIndices[(numTrainingPoints+1):end],:]),
	 MinusPlusOneVector(labels[  shuffledIndices[(numTrainingPoints+1):end]  ]),
	copy(labels2[  shuffledIndices[(numTrainingPoints+1):end]  ]))
end

function bs(val::Float64)
	if isfinite(val)
		out = @sprintf("% .3e", val)
	elseif isnan(val)
		out = "       NaN"
	else
		out = "       Inf"
	end	
	out
end


# function StrainTestRandomSeparate(features,labels)
# 	srand(1)
# 	shuffledIndices = shuffle([1 : size(labels)[1];])
# 	numTrainingPoints = div(size(labels)[1]*3,4)
# 	# println(numTrainingPoints)
# 	# println(shuffledIndices[1:numTrainingPoints      ])
# 	# println(features)
# 	(copy(features[shuffledIndices[1:numTrainingPoints      ]]),
# 	copy(labels  [shuffledIndices[1:numTrainingPoints      ]  ]),
# 	numTrainingPoints,
# 	copy(features[shuffledIndices[(numTrainingPoints+1):end]]),
# 	copy(labels[  shuffledIndices[(numTrainingPoints+1):end]  ]))
# end

function createBLOracles(trf,trl,numTrainingPoints, tef, tel, L2reg::Bool, outputLevel,thisDataName)
	
	outputLevel > 0  && println("Fraction of ones in training set: $(trl.numPlus/length(trl))")
	outputLevel > 0  && println("Fraction of ones in testing  set: $(tel.numPlus/length(tel))")
	
	trft=trf'
	gradientOracle(W,index) = BL_get_f_g(trft, trl,W,index)
	gradientOracle(W) = BL_get_f_g(trf, trl,W)
	testFunction(W) = BL_for_output(tef, tel,W)
		
	function outputsFunction(W)
		(f,pcc, mcc, tp, tn, fp, fn) = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(bs(yo[1])*" "*bs(f)*" "*bs(pcc)*" "*bs(mcc),[f, pcc, mcc, tp, tn, fp, fn, yo[1]])
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

	(mygradientOracle, size(trf)[2], numTrainingPoints, myrestoreGradient, csDataType, "BL", Outputter(outputsFunction,  "    f-train       f         pcc        mcc",8), L2reg, thisDataName)
end


function createMLOracles(trf,trl,numTrainingPoints,numClasses, tef, tel, L2reg::Bool, outputLevel, thisDataName)
	
	trft=trf'
	gradientOracle(W,index) = ML_get_f_g(trft, trl,W,index)
	gradientOracle(W) = ML_get_f_g(trf, trl,W)
	testFunction(W) = ML_for_output(tef, tel,W)
	
	function outputsFunction(W)
		ye = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(bs(yo[1])*" "*bs(ye[1]) *" "*bs(ye[2]), [ye[1], ye[2], yo[1]])
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
	
	(mygradientOracle, size(trf)[2]*numClasses,  numTrainingPoints, myrestoreGradient, csDataType, "ML", Outputter(outputsFunction,  "     f-train       f         pcc    ",3), L2reg, thisDataName)
end


function createSBLOracles(features,labels, setOfOnes, L2reg::Bool, outputLevel)
	numDatapoints = length(labels)
	numFeatures = length(features[1])

	outputLevel > 0  && println("Creating oracles")
	(trf,trl,numTrainingPoints, tef, tel) = StrainTestRandomSeparate(features,labels)
	trl=MinusPlusOneVector(trl,setOfOnes)
	outputLevel > 0  && println("Fraction of ones in training set: $(trl.numPlus/length(trl))")
	tel=MinusPlusOneVector(tel,setOfOnes)
	outputLevel > 0  && println("Fraction of ones in testing  set: $(tel.numPlus/length(tel))")

	gradientOracle(W,index) = SBL_get_f_g(trf, trl,W,index)
	gradientOracle(W) = SBL_get_f_g(trf, trl,W)
	testFunction(W) = SBL_for_output(tef, tel,W)

	function outputsFunction(W)
		ye = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(@sprintf("% .3e % .3e % .3e % .3e % .3e",ye[1], ye[2], ye[3], ye[4], yo[1]), [ye[1], ye[2], ye[3], ye[4], yo[1]])
	end

	restoreGradient(cs,indices) = SBL_restore_gradient(trf, trl,cs,indices)

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
	(mygradientOracle,numTrainingPoints,numVars,myrestoreGradient,csDataType, "SBL",  Outputter(outputsFunction, "       f         pcc        fp         fn       f-train  ",5))
end