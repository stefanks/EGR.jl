using Base.Test
using EGR

println("TestVerify")

for (gradientOracle, numVars, numTP, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem)  in Oracles
			
	srand(1)

	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	tol = 1e-6
	
	xs = Any[zeros(numVars,1),2*rand(numVars,1)-1, randn(numVars,1)]
	xtexts = ["zeros(numVars,1)","2*rand(numVars,1)-1", "randn(numVars,1)"]
	for i in 1:3
		println("  For x = $(xtexts[i])")
		x=xs[i]
		# println("  x = $(x)")
		est=zeros(numVars)
		for i=1:numTP
			(f,g1)= gradientOracle(x,i)
			est+=g1
		end
		g=est/numTP
		# println("  g = $(g)")
		gDiff = zeros(numVars)
		passedDiff = false
		for displacementAccuracy in 1:15
			for j in 1:numVars
				a=zeros(numVars,1)
				b=zeros(numVars,1)
				a[j] = 10.0^(-displacementAccuracy)
				b[j] = -10.0^(-displacementAccuracy)
				a+=x
				b+=x
				fa= gradientOracle(a)
				fb= gradientOracle(b)
				gDiff[j] = (fa-fb)/(2*10.0^(-displacementAccuracy))
			end

			# println("  gDiff = $(gDiff)")
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
		
		
	end
end

println("TestVerify successful!")
println()