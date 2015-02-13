function getSequential(numTrainingPoints,gradientOracle,restoreGradient)
	srand(1)
	indices = [1:numTrainingPoints]
	while true
		for i in indices
			g(x) = gradientOracle(x,i)
			cs(cs) = restoreGradient(cs,i)
			produce((g,cs))
		end
		shuffle!(indices)
	end
end

(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient) = createOracles(features,labels,numFeatures,numDatapoints,Set([1.0]); L2reg=false,outputLevel=0)

	

# alg(numTrainingPoints, numVars, stepSize, outputsFunction, SGStepParams(getNextSampleFunction), SGData_hold(), OutputOpts(),computeSGStep; maxG=10)
#
#
# alg(numTrainingPoints, numVars, stepSize, outputsFunction, GDStepParams(gradientOracle, numTrainingPoints), GDData_hold(), OutputOpts(),computeGDStep; maxG=1000)
#
# k=0
#
# s(k,I)=min(k,I)
# u(k,I)= min(k+1, numTrainingPoints - I)
# beta = 1
# alg(numTrainingPoints, numVars, stepSize, outputsFunction, EGRStepParams(s, u, beta, getNextSampleFunction), EGRdata_hold(numVars),OutputOpts(),naturalEGRS; maxG=1000)
#


## If s(k) = 0, u(k) = 1, gamma is natural, then egrs is equivalent to gd!!!
	
stepSize(k)=0.1

getNextSampleFunction = Task(() -> getSequential(numTrainingPoints,gradientOracle,restoreGradient))

println("If s(k) = 0, u(k) = 1, gamma is natural, then egrs is equivalent to gd!!!")


maxG = 10*numTrainingPoints

alg(Opts(zeros(numVars),stepSize; maxG=maxG), SGStepParams(getNextSampleFunction), SGData_hold(), OutputOpts(outputsFunction,outputLevel=2), computeSGStep)

s(k,I)=0
u(k,I)= 1
beta = 1

alg(Opts(zeros(numVars),stepSize; maxG=maxG), EGRStepParams(s, u, beta, getNextSampleFunction), EGRdata_hold(numVars), OutputOpts(outputsFunction,outputLevel=2), naturalEGRS)