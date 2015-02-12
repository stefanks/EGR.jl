(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient) = createOracles(features,labels,numFeatures,numDatapoints,Set([1.0]); L2reg=false,outputLevel=0)
	
stepSize(k)=0.01
gd(gradientOracle,numVars,stepSize,outputsFunction,OutputOpts();maxG=10000)