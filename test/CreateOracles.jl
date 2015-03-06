
function CreateOracles(Oracles)

	println("Starting to create oracles")
	L2regs=[
	false,
	true
	]


	for ThisKey in keys(FullDict)
		ThisData=FullDict[ThisKey]
		trf = ThisData["trf"]
		trl = ThisData["trl"]
		trl2 = ThisData["trl2"]
		numTrainingPoints = ThisData["numTrainingPoints"]
		tef = ThisData["tef"]
		tel = ThisData["tel"]
		tel2 = ThisData["tel2"]
		numClasses = ThisData["numClasses"]
	
		for L2reg in L2regs
			
			
			(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName) = createBLOracles(trf, trl, numTrainingPoints, tef, tel, L2reg, 0, ThisData["name"])
			
			push!(Oracles, (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, (t)-> Problem(L2reg, thisDataName, LossFunctionString, (w)->gradientOracle(w), numTrainingPoints, t)))
			
			(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName) = createMLOracles(trf, trl2, numTrainingPoints, numClasses, tef, tel2, L2reg, 0, ThisData["name"]) 
			
			push!(Oracles,(gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName,  (t)-> Problem(L2reg, thisDataName, LossFunctionString, (w)->gradientOracle(w), numTrainingPoints, t)))
			
			
			
			
		end
	end

end

CreateOracles(Oracles)