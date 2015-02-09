
module ScriptsModule


importall MinusPlusOneVectorModule
importall BinaryLogisticRegressionModule

export myScript

include("GradientTest.jl")
include("myIO.jl")
include("myAlgs.jl")



function run_alg(trainFunction::Function,testFunction::Function,x)
	trainFunction(x)
	println()
end

function L2regGradient(gradientOracle::Function, L2param::Float64, a,b)

 	W = a
	
	res = gradientOracle(a,b)
	
	( res[1] + (1/2)*L2param*(W'*W),res[2]+ L2param*W, res[3])

end
#
# function BinaryLogisticRegression(features,labels::Vector{Float64},l2reg=1e-4,fractionTraining=0.75)
#
# 	trainFunction(x)=get_f_g_cs(features,labels, x)
# 	testFunction(x)=get_f_g_cs(features,labels, x)
# 	(trainFunction, testFunction)
# end



function myScript(datasetArray::Array{Dict,1})
	
	sort!(datasetArray,by=x->int(x["numTotal"]))	 

	datasetArray=datasetArray[[2,5]]

	for datasetHT in datasetArray
		println()
		println(datasetHT["name"])
		numVars = int(datasetHT["nFeatures"])
		numDatapoints = int(datasetHT["nDatapoints"])
	
		(features,labels) = myIO.readBin(datasetHT["path"]*datasetHT["name"]*".bin",numDatapoints,numVars)

		(trf,trl,numTrainingPoints, tef, tel) = trainTestRandomSeparate(features,labels)
		trl=MinusPlusOneVector(trl,Set([1.0]))
		tel=MinusPlusOneVector(tel,Set([1.0]))

		gradientOracle(W,indices) = get_f_g_cs(trf, trl,W,indices)
		gradientOracle(W) = get_f_g_cs(trf, trl,W)
		testFunction(W) = get_f_pcc(tef, tel,W)

		# MyTests.GradientTest(numVars,numTrainingPoints,gradientOracle)

		stepSize(k)=1/sqrt(k)

		(results_k, results_f, results_pcc, results_x ) = MyAlgs.sg(gradientOracle,numTrainingPoints,numVars,stepSize,testFunction,iter=10*numTrainingPoints)
	
		# stepSize(k)=1
		# MyAlgs.gd(gradientOracle,numTrainingPoints,numVars,stepSize,testFunctionValue)
	
	end

end

end