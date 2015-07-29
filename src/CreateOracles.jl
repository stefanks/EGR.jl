function bs(val::Float64)
	if isfinite(val)
		out = @sprintf("% .3e", val)
	elseif isnan(val)
		out = "       NaN"
	else
		out = "       Inf"
	end	
	out
end


function createBLOracles(trf,trl,numTrainingPoints, tef, tel, L2reg::Bool; outputLevel::Int64=0)
	
	outputLevel > 0  && println("Fraction of ones in training set: $(trl.numPlus/length(trl))")
	outputLevel > 0  && println("Fraction of ones in testing  set: $(tel.numPlus/length(tel))")
	
	trft=trf'
	gradientOracle(W,index) = BL_get_f_g(trft, trl,W,index)
	gradientOracle(W) = BL_get_f(trf, trl,W)
	testFunction(W) = BL_for_output(tef, tel,W)
		
	function outputsFunction(W)
		(f,pcc, mcc, tp, tn, fp, fn) = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(bs(yo)*" "*bs(f)*" "*bs(pcc)*" "*bs(mcc),[f, pcc, mcc, tp, tn, fp, fn, yo])
	end
		
	restoreGradient(cs,indices) = BL_restore_gradient(trft, trl,cs,indices)
	
	if L2reg
		mygradientOracle(a) = L2regGradient(gradientOracle, 1/numTrainingPoints, a)
		mygradientOracle(a, b) = L2regGradient(gradientOracle, 1/numTrainingPoints, a, b)
		csDataType = Matrix{Float64}
	else
		mygradientOracle=gradientOracle
		csDataType = Matrix{Float64}
	end

	(mygradientOracle, size(trf)[2], numTrainingPoints, csDataType, "BL", Outputter(outputsFunction,  "     f-train       f         pcc        mcc",8), L2reg)
end


function createMLOracles(trf,trl,numTrainingPoints,numClasses, tef, tel, L2reg::Bool; outputLevel::Int64=0)
	trft=trf'
	gradientOracle(W,index) = ML_get_f_g(trft, trl,W,index)
	gradientOracle(W) = ML_get_f(trf, trl,W)
	testFunction(W) = ML_for_output(tef, tel,W)
	
	function outputsFunction(W)
		(f,pcc) = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(bs(yo)*" "*bs(f) *" "*bs(pcc), [f, pcc, yo])
	end
	
	restoreGradient(cs,indices) = ML_restore_gradient(trft, trl,cs,indices)
	if L2reg
		mygradientOracle(a) = L2regGradient(gradientOracle, 1/numTrainingPoints, a)
		mygradientOracle(a, b) = L2regGradient(gradientOracle, 1/numTrainingPoints, a, b)
		csDataType=Matrix{Float64}
	else
		mygradientOracle=gradientOracle
		myrestoreGradient=restoreGradient
		csDataType=Matrix{Float64}
	end
	
	(mygradientOracle, size(trf)[2]*numClasses,  numTrainingPoints, csDataType, "ML", Outputter(outputsFunction,  "     f-train       f         pcc    ",3), L2reg)
end


function createSBLOracles(trf,trl,numTrainingPoints, tef, tel, L2reg::Bool; outputLevel::Int64=0)
	
	outputLevel > 0  && println("Fraction of ones in training set: $(trl.numPlus/length(trl))")
	outputLevel > 0  && println("Fraction of ones in testing  set: $(tel.numPlus/length(tel))")
	
	trft=trf'
	gradientOracle(W,index) = SBL_get_f_g(trft, trl,W,index)
	gradientOracle(W) = SBL_get_f(trf, trl,W)
	testFunction(W) = SBL_for_output(tef, tel,W)
		
	function outputsFunction(W)
		(f,pcc, mcc, tp, tn, fp, fn) = testFunction(W)
		yo = gradientOracle(W)
		ResultFromOO(bs(yo)*" "*bs(f)*" "*bs(pcc)*" "*bs(mcc),[f, pcc, mcc, tp, tn, fp, fn, yo])
	end
		
	restoreGradient(cs,indices) = SBL_restore_gradient(trft, trl,cs,indices)
	
	if L2reg
		mygradientOracle(a) = L2regGradient(gradientOracle, 1/numTrainingPoints, a)
		mygradientOracle(a, b) = L2regGradient(gradientOracle, 1/numTrainingPoints, a, b)
		csDataType = Matrix{Float64}
	else
		mygradientOracle=gradientOracle
		csDataType = SparseMatrixCSC{Float64,Int64}
	end

	(mygradientOracle, size(trf)[2], numTrainingPoints, csDataType, "SBL", Outputter(outputsFunction,  "    f-train       f         pcc        mcc",8), L2reg)
end