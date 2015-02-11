stepSize(k)=1/sqrt(k)
(results_k, results_f, results_pcc, results_x ) = MyAlgs.sg(gradientOracle,numTrainingPoints,numVars,stepSize,testFunction,iter=10*numTrainingPoints)