function Generate6dpProblem()


	trf = float([-1  1
				-1 -1
			    -1 -2
			    -1 -3])
			
	trl=MinusPlusOneVector([1,1,-1,-1])

	tef = float([ 1 -1
			    -2 -2])
			
	tel=MinusPlusOneVector([1,-1])

	numVars=2
	numDatapoints=4
		
	gradientFunction(W,index)=get_f_g_cs(trf,trl,W,index)
	gradientFunction(W)=get_f_g_cs(trf,trl,W)
	restoreGradient(cs,indices) = get_g_from_cs(trf,trl,cs,indices)
	testFunction(W) = get_f_pcc(tef,tel,W)
	outputsFunction(W) = (testFunction(W), gradientFunction(W)[1])
	
	(numVars, numDatapoints,gradientFunction, restoreGradient,outputsFunction)
end