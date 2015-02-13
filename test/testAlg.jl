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

# alg(numTrainingPoints, numVars, stepSize, outputsFunction, EGRStepParams(s, u, beta, getNextSampleFunction), EGRdata_hold(numVars),OutputOpts(),naturalEGRS; maxG=1000)
#


println("If s(k) = 0 and then numTrainingPoints, u(k) = numTrainingPoints, then 0 , gamma is natural, then egrs is equivalent to gd!!!")

stepSize(k)=0.1
function sLikeGd(k,numTrainingPoints)
	k==0 ? 0 : numTrainingPoints
end
function uLikeGd(k,numTrainingPoints)
	k==0 ? numTrainingPoints : 0
end
s(k,I) = sLikeGd(k,numTrainingPoints)
u(k,I) =  uLikeGd(k,numTrainingPoints)
beta(k) =1 - 1/sqrt(k+1)

maxG = 10*numTrainingPoints


getNextSampleFunction = Task(() -> getSequential(numTrainingPoints,gradientOracle,restoreGradient))


alg(Opts(zeros(numVars),stepSize; maxG=maxG), EGRsd(s, u, beta, getNextSampleFunction,numVars),  OutputOpts(outputsFunction,outputLevel=2), naturalEGRS)


alg(Opts(zeros(numVars),stepSize; maxG=maxG), GDsd(getFullGradient, numTrainingPoints),  OutputOpts(outputsFunction,outputLevel=2), naturalEGRS)

stepSize(k)=0.1

println("If s(k) = 0, u(k) = 1, gamma is natural, then egrs is equivalent to sgs!!!")



alg(Opts(zeros(numVars),stepSize; maxG=maxG), SGsd(getNextSampleFunction), OutputOpts(outputsFunction,outputLevel=2), computeSGStep)

s(k,I)=0
u(k,I)= 1

alg(Opts(zeros(numVars),stepSize; maxG=maxG), EGRsd(s, u, beta, getNextSampleFunction,numVars), OutputOpts(outputsFunction,outputLevel=2), naturalEGRS)