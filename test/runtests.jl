using Base.Test
using EGR
using Redis

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

function M1P1Test()
	a=MinusPlusOneVector([1,1,-1])
	b=MinusPlusOneVector([1,1,-1.0])
	c=MinusPlusOneVector([1,1,-1],Set([-1]))	
	println(a[1])
	println(b[2:3])
	println(c[[1,3]])
	println(size(a))
	true
end

k=0

function getSequential(numDatapoints,gradientFunction,restoreGradient)
	global k+=1
	if k<=numDatapoints
		k
	else
		error("Out of range")
	end
	g(x) = gradientFunction(x,k)
	cs(cs) = restoreGradient(cs,k)
	(g,cs)
end

function EGRTest(numVars, numDatapoints,gradientFunction,restoreGradient,outputsFunction)


	getNextSampleFunction() = getSequential(numDatapoints,gradientFunction,restoreGradient)
	
	stepSize(k)=1/sqrt(k+1)
	s(k,I)=min(k,I)
	u(k,I)= min(k+1, numDatapoints - I)
	beta = 1
	egr(
		numDatapoints,
		numVars,
		stepSize,
		outputsFunction,
		s,
		u,
		beta,
		getNextSampleFunction,
		OutputOpts();
		maxG=1000)
	true
end
features = float([-1  1
			-1 -1
			 1 -1
		    -2 -2
		    -1 -2
		    -1 -3])
			
labels=MinusPlusOneVector([1,1,1,-1,-1,-1])

numVars=2
numDatapoints=6
		
gradientFunction(W,index)=get_f_g_cs(features,labels,W,index)
gradientFunction(W)=get_f_g_cs(features,labels,W)

@test GradientTest(numVars, numDatapoints,gradientFunction)

@test M1P1Test()
	
restoreGradient(cs,indices) = get_g_from_cs(features,labels,cs,indices)


testFunction(W) = get_f_pcc(features,labels,W)
	
outputsFunction(W) = (testFunction(W), gradientFunction(W)[1])
	

@test EGRTest(numVars, numDatapoints,gradientFunction,restoreGradient,outputsFunction)