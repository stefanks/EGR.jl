function GradientTest(numVars::Integer, numDatapoints::Integer,gradientFunction::Function)

	println("Starting Gradient test...")
	
	passed = true
	
	tol = 1e-13
	
	x=zeros(numVars)
	(f,g, margins)= gradientFunction(x)
	(f,g1, margins)= gradientFunction(x,1:div(numDatapoints,2))
	(f,g2, margins)= gradientFunction(x,(div(numDatapoints,2)+1):numDatapoints)
	est1=(div(numDatapoints,2)*g1+(numDatapoints-div(numDatapoints,2))*g2)/numDatapoints
	relError = norm(est1-g)/norm(g)
	println("relError = $relError")
	if relError>tol 
		error("Did not pass!")
		passed=false
	end
	est2=zeros(numVars)
	for i=1:numDatapoints
		(f,g1, margins)= gradientFunction(x,i)
		est2+=g1
	end
	est2=est2/numDatapoints
	relError = norm(est2-g)/norm(g)
	println("relError = $relError")
	if relError>tol 
		error("Did not pass!")
		passed=false
	end
	
	x=2*rand(numVars)-1
	(f,g, margins)= gradientFunction(x)
	(f,g1, margins)= gradientFunction(x,1:div(numDatapoints,2))
	(f,g2, margins)= gradientFunction(x,(div(numDatapoints,2)+1):numDatapoints)
	est1=(div(numDatapoints,2)*g1+(numDatapoints-div(numDatapoints,2))*g2)/numDatapoints
	relError = norm(est1-g)/norm(g)
	println("relError = $relError")
	if relError>tol 
		error("Did not pass!")
		passed=false
	end
	est2=zeros(numVars)
	for i=1:numDatapoints
		(f,g1, margins)= gradientFunction(x,i)
		est2+=g1
	end
	est2=est2/numDatapoints
	relError = norm(est2-g)/norm(g)
	println("relError = $relError")
	if relError>tol 
		error("Did not pass!")
		passed=false
	end

	println("Gradient test passed!")
	passed
end

include("Generate6dpProblem.jl")
(numVars, numDatapoints,gradientFunction, restoreGradient,outputsFunction)=Generate6dpProblem()

@test GradientTest(numVars, numDatapoints,gradientFunction)