

L2regs=[
false,
true
]

createOracleFunctionArray = 
[
(features, labels, L2reg, outputLevel) -> createBLOracles(features, labels, Set([1.0]), L2reg, outputLevel),
(features, labels, L2reg, outputLevel) -> createMLOracles(features, labels, L2reg, outputLevel)
]


for ThisKey in keys(FullDict)
	println(ThisKey)
	ThisData=FullDict[ThisKey]
	println(ThisData)
	println(typeof(ThisData))
	trf = ThisData["trf"]
	trl = ThisData["trl"]
	numTrainingPoints = ThisData["numTrainingPoints"]
	tel = ThisData["tel"]
	tef = ThisData["tef"]
	
	for L2reg in L2regs
		(gradientOracle, numVars, outputsFunction, restoreGradient, csDataType, outputStringHeader,  LossFunctionString, numOutputsFromOutputsFunction) = createBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg, 0)
		push!(Problems, Problem(L2reg, ThisData["name"], LossFunctionString, ()->0, numTrainingPoints, Task(() -> getSequential(numTrainingPoints, gradientOracle, restoreGradient))))
	end
end