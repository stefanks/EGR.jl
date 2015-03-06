using Base.Test
using EGR


for thisOracle in Oracles
			
	(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName) = thisOracle
			
	VerifyGradient(numVars,gradientOracle,numTrainingPoints; outputLevel=1)
	VerifyRestoration(numVars,gradientOracle,restoreGradient; outputLevel=2)
end



