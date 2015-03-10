function createClassLabels(labels; outputLevel = 0)

	numDatapoints = length(labels)

	outputLevel > 0  && println("Creating class labels")

	classesDict=(Any => (Int64, Int64))[]

	currentClass =0
	classLabels = zeros(Float64,numDatapoints )
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

function trainTestRandomSeparate(features,labels::MinusPlusOneVector, labels2::Vector{Float64}; outputLevel = 0)
	srand(1)
	shuffledIndices = shuffle([1 : length(labels)])
	numTrainingPoints = div(length(labels)*3,4)
	outputLevel > 0  && println("numTrainingPoints = $numTrainingPoints")
	outputLevel > 0  && println("numTestingPoints = $(length(labels)-numTrainingPoints)")
	(copy(features[shuffledIndices[1:numTrainingPoints      ],:]),
	 MinusPlusOneVector(labels  [shuffledIndices[1:numTrainingPoints      ]  ]),
	copy(labels2  [shuffledIndices[1:numTrainingPoints      ]  ]),
	 numTrainingPoints,
	 copy(features[shuffledIndices[(numTrainingPoints+1):end],:]),
	 MinusPlusOneVector(labels[  shuffledIndices[(numTrainingPoints+1):end]  ]),
	copy(labels2[  shuffledIndices[(numTrainingPoints+1):end]  ]))
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

