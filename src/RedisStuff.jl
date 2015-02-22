using Redis 

function returnIfExists(client::RedisConnection, problem::Problem, opts::Opts, sd::StepData, wantOutputs::Int64)
	
	wantGnum = opts.maxG
	
	longKey = problem.name*":"*problem.lossFunctionString*":"*string(problem.L2reg)*":"sd.stepString*":"*"const"*":"*string(opts.stepSizePower)
	
	if ~exists(client, longKey*":gnum")
		return false
	else
		existingListOfgunum=Int64[]
		existingListRes1=Float64[]
		existingListOfk=Int64[]
		
		arrayOfStrings  = lrange(client, longKey*":gnum", 0, -1)
		for i in arrayOfStrings
			push!(existingListOfgunum, int(i))
		end
		arrayOfStrings  = lrange(client, longKey*":1", 0, -1)
		for i in arrayOfStrings
			push!(existingListRes1, float64(i))
		end
		arrayOfStrings  = lrange(client, longKey*":k", 0, -1)
		for i in arrayOfStrings
			push!(existingListOfk, int(i))
		end
		
		atWhichIndexHaveEnough = findfirst((i)->i>=wantGnum,existingListOfgunum)
		# INEQUALITY SIGNS SET TO MAKE THIS AS RARE AS POSSIBLE.
		
		if  atWhichIndexHaveEnough >= wantOutputs
			warn("atWhichIndexHaveEnough >= wantOutputs")
			warn("Already exists, using existing! atWhichIndexHaveEnough=$atWhichIndexHaveEnough wantGnum = $wantGnum wantOutputs=$wantOutputs")
		elseif  existingListOfk[end] +1 == length(existingListOfk)
			warn("existingListOfk[end] +1 == length(existingListOfk)")
			warn("Already exists, using existing! atWhichIndexHaveEnough=$atWhichIndexHaveEnough wantGnum = $wantGnum wantOutputs=$wantOutputs")
		elseif isnan(existingListRes1[end]) && wantGnum>=existingListOfgunum[end]
			warn("isnan(existingListRes1[end]) && wantGnum>=existingListOfgunum[end]")
			warn("Already exists, using existing! atWhichIndexHaveEnough=$atWhichIndexHaveEnough wantGnum = $wantGnum wantOutputs=$wantOutputs")
		else
			warn("Already exists, but re-running! atWhichIndexHaveEnough=$atWhichIndexHaveEnough wantGnum = $wantGnum wantOutputs=$wantOutputs")
			return false
		end
			
		arrayss = Vector{Float64}[]
		for outputNumber in 1:5
			push!(arrayss, Float64[])
			fullRange = lrange(client, longKey*":$outputNumber",0,-1)
			for i in fullRange
				push!(arrayss[outputNumber], float(i))
			end
		end
			
		kk=hcat(arrayss[1], arrayss[2], arrayss[3], arrayss[4],arrayss[5])
			
		return (
		"Already exists!"
		, 
		int(lrange(client, longKey*":k", 0,-1))
		,
		int(lrange(client, longKey*":gnum",0, -1))
		,
		kk
		,
		Float64[]
		# float(lrange(client, longKey*":x",0,-1))
		)
	end
end

function writeFunction(client::RedisConnection, problem::Problem, opts::Opts, sd::StepData,  k, gnum, fromOutputsFunction, x)

writeLoc = problem.name*":"*problem.lossFunctionString*":"*string(problem.L2reg)*":"sd.stepString*":"*"const"*":"*string(opts.stepSizePower)
	
if ~exists(client, writeLoc*":k")
	rpush(client, writeLoc*":k",k)
	rpush(client, writeLoc*":gnum",gnum)
	for j in 1:length(fromOutputsFunction.resultLine)
		rpush(client, writeLoc*":$j",fromOutputsFunction.resultLine[j])
	end
else
	arrayOfStrings  = lrange(client, writeLoc*":gnum", 0, -1)
	existingListOfgunum=Int64[]
	currentIndex=0
	for i in 1:length(arrayOfStrings)
		if gnum==int(arrayOfStrings[i])
			return
		end
		push!(existingListOfgunum, int(arrayOfStrings[i]))
		if int(arrayOfStrings[i])>gnum
			currentIndex=i
			break
		end
	end
	if currentIndex ==0
		rpush(client, writeLoc*":k",k)
		rpush(client, writeLoc*":gnum",gnum)
		for j in 1:length(fromOutputsFunction.resultLine)
			rpush(client, writeLoc*":$j",fromOutputsFunction.resultLine[j])
		end
	else
		linsert(client, writeLoc*":k" ,"before", lindex(client,writeLoc*":k",currentIndex  )   ,k)
		linsert(client, writeLoc*":gnum" ,"before", lindex(client,writeLoc*":gnum",currentIndex  )   ,gnum)
		for j in 1:length(fromOutputsFunction.resultLine)
			linsert(client, writeLoc*":$j" ,"before", lindex(client,writeLoc*":$j",currentIndex  )   ,fromOutputsFunction.resultLine[j])
		end
	end
end
end
