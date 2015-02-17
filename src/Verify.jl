function VerifyGradient(numVars,gradientOracle,numTrainingPoints; outputLevel=2)
	
	srand(1)
	
	outputLevel>0 && println("Verifying Gradient...")

	tol = 1e-6
	
	for x in {zeros(numVars),2*rand(numVars)-1}
	
		(f,g, margins)= gradientOracle(x)
		# println("now f # is of type")
		# 		println(typeof(f))
		
		gDiff = zeros(numVars)
		passedDiff = false
		for displacementAccuracy in 1:15
			for j in 1:numVars
				a=zeros(numVars)
				b=zeros(numVars)
				a[j] = 10.0^(-displacementAccuracy)
				b[j] = -10.0^(-displacementAccuracy)
				a+=x
				b+=x
				(fa,g, margins)= gradientOracle(a)
				(fb,g, margins)= gradientOracle(b)
				# println(typeof(ff))
				# 			println("f = $f")
				# 			println("ff = $ff")
				# 			println("displacementAccuracy = $displacementAccuracy")
				#		println("gDiff[j] = $(gDiff[j])")
				gDiff[j] = (fa-fb)/(2*10.0^(-displacementAccuracy))
			end
			relError = norm(gDiff-g)/norm(g)
			outputLevel>1 && println("  At power = $displacementAccuracy, relError = $relError")
			if relError<=tol 
				passedDiff = true
				break
			end
		end
		if passedDiff == false
			error("F values do not work with gradient!")
		end
		
		(f,g1, margins)= gradientOracle(x,1:div(numTrainingPoints,2))
		(f,g2, margins)= gradientOracle(x,(div(numTrainingPoints,2)+1):numTrainingPoints)
		est1=(div(numTrainingPoints,2)*g1+(numTrainingPoints-div(numTrainingPoints,2))*g2)/numTrainingPoints
		# println("est1 =$est1")
		# println("g =$g")
		relError = norm(est1-g)/norm(g)
		if relError>tol 
			println("relError = $relError")
			error("Did not pass the splitting training points in half test. Average not equal to true gradient!")
		end
		
		est2=zeros(numVars)
		for i=1:numTrainingPoints
			(f,g1, margins)= gradientOracle(x,i)
			est2+=g1
		end
		est2=est2/numTrainingPoints
		relError = norm(est2-g)/norm(g)
		if relError>tol 
			println("relError = $relError")
			error("Did not pass the splitting training points into individuals. Average not equal to true gradient!")
		end
		
	end
	outputLevel>0 && println("Gradient verified!")
end

function VerifyRestoration(numVars,gradientOracle,restoreGradient; outputLevel=2)
	outputLevel>0 && println("Verifying Restoration...")
	tol = 1e-12
	for x in {zeros(numVars),2*rand(numVars)-1}
		(f,g,cs) = gradientOracle(x,1)
		relError = norm(restoreGradient(cs,1)-g)/norm(g)
		if relError>tol 
			println("relError = $relError")
			error("Did not pass restoration verification!")
		end
	end
	outputLevel>0 && println("Restoration verified!")
end