using StatsBase

function egr(
	numDatapoints::Integer,
	numVars::Integer,
	stepSize::Function,
	outputsFunction::Function,
	s::Function,
	u::Function,
	beta,
	getNextSampleFunction::Function,
	outputOpts;
	maxG=typemax(Int64)-35328,
	x=zeros(numVars))

	println("Starting egr-s")
	
	if outputOpts.logarithmic == 1
		expIndices=unique(int(round(logspace(0,log10(maxG),outputOpts.outputNum))));
	else
		expIndices=unique(int(round(linspace(0,maxG,outputOpts.outputNum))));
	end
	
	maxCounter = min(maxG, expIndices[end]);
	
	results_k = Int64[]
	results_f = Float64[]
	results_pcc = Float64[]
	results_x = Array{Float64,1}[]
	x=zeros(numVars)
	
	I=0
	k=0
	gnum=0
	A=zeros(numVars)
	functions=Function[]
	restoreFunctions=Function[]
	y=Array{Float64,1}[]
	xSum=zeros(numVars)
	kOutputs=1
	timein=0
	timeout=0
	
	println("        k    gnum       f         pcc      f-train")
	
	tic()
	while true
		
		U = (I+1):(I+u(k,I))
		
		for i in U
			(a,b) = getNextSampleFunction()
			push!(functions,a)
			push!(restoreFunctions,b)
		end
		
		
		S = StatsBase.sample(1:I,s(k,I);replace=false)
		
		
		
		B=zeros(numVars)
		
		for i in S
			B +=restoreFunctions[i](y[i])
		end
		
		sumy=zeros(numVars)

		for i in [U ; S]
			timeout+=toq()
			tic()
			(f,sampleG,cs) = functions[i](x)
			timein+=toq()
			tic()
			push!(y,cs)
			sumy += sampleG
		end
		
		
		gnum += s(k,I)+u(k,I)	
		
		g = (s(k,I)>0 ? s(k,I)*(beta/I*A): 0 - beta*B + sumy )/(s(k,I)+u(k,I))
		
		x-=stepSize(k)*g
	
		I = I + u(k,I)
		
		A=A-B+sumy
		

		xSum = xSum+x;
		


		timeout+=toq()
		if gnum>= expIndices[kOutputs]
			if outputOpts.average == 1
				xToTest =xSum/(k+1s);
			else
				xToTest =x;
			end
			((f, pcc),f_train) = outputsFunction(x)
            @printf("%2.i %7.i %7.i % .3e % .3e % .3e\n", kOutputs,k, gnum,f, pcc,f_train)
			push!(results_k,k)
			push!(results_f,f )
			push!(results_pcc,pcc )
			push!(results_x,x)
			kOutputs = kOutputs+1;
		end
		tic()
		
		k+=1
		
			
		gnum>=maxG && break
		
		
	end
	timeout+=toq()
	println("time in     sample gradient computation $timein")
	println("time out of sample gradient computation $timeout")
	
	
	println("Finished egr-s")
	(results_k ,results_f ,results_pcc ,results_x )
end

immutable type OutputOpts
	logarithmic::Bool
	outputNum::Int64
	average::Bool
	function OutputOpts(;logarithmic::Bool = true,outputNum::Int64 = 10, average::Bool=false)
		if outputNum>99
			error("outputNum too big")
		end
		new(logarithmic,outputNum, average)
	end
end