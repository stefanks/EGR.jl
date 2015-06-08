using Base.Test
using EGR

println("TestRestore")

for (gradientOracle, numVars, numTrainingPoints, restoreGradient, csDataType, LossFunctionString, myOutputter, L2reg, thisDataName, thisProblem)  in Oracles
			
	srand(1)

	println(" $thisDataName $LossFunctionString L2reg = $L2reg")
	
	tol = 1e-12
	xs = {zeros(numVars,1),2*rand(numVars,1)-1, randn(numVars,1)}
	xtexts = ["zeros(numVars)","2*rand(numVars)-1", "randn(numVars)"]
	for i in 1:3
		print("  For x = $(xtexts[i])")
		x=xs[i]
		(f,g,cs) = gradientOracle(x,1)
		relError = norm(restoreGradient(cs,1)-g)/norm(g)
			println("  relError = $relError")
		if relError>tol 
			println("relError = $relError")
			error("Did not pass restoration verification!")
		end
	end
	
end

println("TestRestore successful!")
println()