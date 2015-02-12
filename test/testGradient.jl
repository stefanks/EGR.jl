
(gradientOracle, numTrainingPoints, numVars, outputsFunction, restoreGradient) = createOracles(features,labels,numFeatures,numDatapoints,Set([1.0]); L2reg=false,outputLevel=0)

println("Starting Gradient test...")
	
tol = 1e-13
	
x=zeros(numVars)
(f,g, margins)= gradientOracle(x)
(f,g1, margins)= gradientOracle(x,1:div(numTrainingPoints,2))

(f,g2, margins)= gradientOracle(x,(div(numTrainingPoints,2)+1):numTrainingPoints)

est1=(div(numTrainingPoints,2)*g1+(numTrainingPoints-div(numTrainingPoints,2))*g2)/numTrainingPoints
relError = norm(est1-g)/norm(g)
println("relError = $relError")
if relError>tol 
	error("Did not pass!")
	passed=false
end
est2=zeros(numVars)
for i=1:numTrainingPoints
	(f,g1, margins)= gradientOracle(x,i)
	est2+=g1
end
est2=est2/numTrainingPoints
relError = norm(est2-g)/norm(g)
println("relError = $relError")
if relError>tol 
	error("Did not pass!")
	passed=false
end
	
x=2*rand(numVars)-1
(f,g, margins)= gradientOracle(x)
(f,g1, margins)= gradientOracle(x,1:div(numTrainingPoints,2))
(f,g2, margins)= gradientOracle(x,(div(numTrainingPoints,2)+1):numTrainingPoints)
est1=(div(numTrainingPoints,2)*g1+(numTrainingPoints-div(numTrainingPoints,2))*g2)/numTrainingPoints
relError = norm(est1-g)/norm(g)
println("relError = $relError")
if relError>tol 
	error("Did not pass!")
	passed=false
end
est2=zeros(numVars)
for i=1:numTrainingPoints
	(f,g1, margins)= gradientOracle(x,i)
	est2+=g1
end
est2=est2/numTrainingPoints
relError = norm(est2-g)/norm(g)
println("relError = $relError")
if relError>tol 
	error("Did not pass!")
	passed=false
end

println("Gradient test passed!")