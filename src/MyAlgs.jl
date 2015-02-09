module MyAlgs



function sg(gradientFunction::Function,
	numDatapoints::Integer,
	numVars::Integer,
	stepSize::Function,
	testFunction::Function;
	iter=numDatapoints*100,
	numOutputs=10)
	println("Starting sg")
	
	results_k = Int64[]
	results_f = Float64[]
	results_pcc = Float64[]
	results_x = Array{Float64,1}[]
	x=zeros(numVars)
	for k=1:iter
		i=rand(1:numDatapoints)
		(f,g, margins) = gradientFunction(x,i)
		x-=stepSize(k)*g
		if k%div(iter,numOutputs)==0
			(f, pcc) = testFunction(x)
			@printf("% .6f % .6f\n", f, pcc)
			push!(results_k,k)
			push!(results_f,f )
			push!(results_pcc,pcc )
			push!(results_x,x)
		end
	end
	println("Finished sg")
	(results_k ,results_f ,results_pcc ,results_x )
end

function gd(gradientFunction::Function,numDatapoints::Integer,numVars::Integer,stepSize::Function,testFunction::Function,iter=100)
	println("Starting gd")
	x=zeros(numVars)
	for k=1:iter
		(f,g, margins)= gradientFunction(x)
		x-=stepSize(k)*g
		if k%div(iter,40)==0
			(f, pcc) = testFunction(x)
			@printf("% .6f % .6f\n", f, pcc)
		end
	end
	println("Finished gd")
end

end