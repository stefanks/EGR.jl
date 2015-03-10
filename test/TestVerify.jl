using Base.Test
using EGR

println("TestVerify")

for (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem,dims)  in Oracles
			
	srand(1)

	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	tol = 1e-6
	
	xs = {zeros(dims),2*rand(dims)-1, randn(dims)}
	xtexts = ["zeros(numVars)","2*rand(numVars)-1", "randn(numVars)"]
	for i in 1:3
		println("  For x = $(xtexts[i])")
		x=xs[i]
		(f,g)= gradientOracle(x)
		gDiff = zeros(dims)
		passedDiff = false
		for displacementAccuracy in 1:15
			for j in 1:numVars
				a=zeros(dims)
				b=zeros(dims)
				a[j] = 10.0^(-displacementAccuracy)
				b[j] = -10.0^(-displacementAccuracy)
				a+=x
				b+=x
				(fa,g)= gradientOracle(a)
				(fb,g)= gradientOracle(b)
				gDiff[j] = (fa-fb)/(2*10.0^(-displacementAccuracy))
			end
			relError = norm(gDiff-g)/norm(g)
			println("   For displacementAccuracy = $displacementAccuracy, relError = $relError")
			if relError<=tol 
				passedDiff = true
				break
			end
		end
		if passedDiff == false
			error("F values do not work with gradient!")
		end
		
		est=zeros(numVars)
		for i=1:numTrainingPoints
			(f,g1, margins)= gradientOracle(x,i)
			est+=g1
		end
		est=est/numTrainingPoints
		relError = norm(est-g)/norm(g)
		if relError>tol 
			println("relError = $relError")
			error("Did not pass the splitting training points into individuals. Average not equal to true gradient!")
		end
		
	end
end

println("TestVerify successful!")
println()