using Redis 

function returnIfExists(client::RedisConnection, problem::Problem, opts::Opts, sd::StepData, expIndices::Vector{Int64}; outputLevel::Int64=0)
	
	longKey = problem.name*":"*problem.lossFunctionString*":"*string(problem.L2reg)*":"sd.stepString*":"*"const"*":"*string(opts.stepSizePower)
	
	if ~exists(client, longKey*":gnum")
		outputLevel>0 && println("RUN: key does not exist")
		return false
	else
		existingListOfgunum=Int64[]
		existingListRes1=Float64[]
		existingListOfk=Int64[]
		existingListOfOrigWant=Int64[]
		
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
		arrayOfStrings  = lrange(client, longKey*":origWant", 0, -1)
		for i in arrayOfStrings
			push!(existingListOfOrigWant, int(i))
		end
		
		# CHECK IF HAVE AN OUTPUT FOR EACH INDEX IN EXPINDICES!!!!!
		i,j = 1,1
		while i<=length(expIndices)
			val = expIndices[i]
			while existingListOfgunum[j]<val
				j+=1
				outputLevel>1 && println("existingListOfgunum[j] = $(existingListOfgunum[j])")
				if j<=length(existingListOfgunum) && isnan(existingListRes1[j])
					outputLevel>0 && println("Found NaN at $j, when existingListOfgunum[$j] = $(existingListOfgunum[j]) and val = $val")
					i = -1
					break	
				end
				if j>length(existingListOfgunum)
					outputLevel>0 && println("RE-RUN: could not find element >= $val in existingListOfgunum")
					return false
				end
			end
			if i==-1
				break
			end
			if existingListOfOrigWant[j]<=val
				i+=1
				outputLevel>1 && println("val = $val")
				outputLevel>1 && println("existingListOfOrigWant[j] = $(existingListOfOrigWant[j])")
			else
				outputLevel>0 && println("RE-RUN: for val = $val existingListOfOrigWant[j] is $(existingListOfOrigWant[j]), it is not small enough")
				return false
			end
		end
		
		i=1
		while Redis.exists(client, longKey*":$i")
			i+=1
		end
		numOutputs = i-1
			
		kk = zeros(length(arrayOfStrings),0)
		for outputNumber in 1:numOutputs
			arrayss = Float64[]
			fullRange = lrange(client, longKey*":$outputNumber",0,-1)
			for i in fullRange
				push!(arrayss, float(i))
			end
			kk=hcat(kk, arrayss)
		end

		outputLevel>0 && println("NO RE-RUN! Using existing")
			
		return (
		"Already exists!"
		, 
		int(lrange(client, longKey*":k", 0,-1))
		,
		int(lrange(client, longKey*":gnum",0, -1))
		,
		kk
		)
	end
end

function writeFunction(client::RedisConnection, problem::Problem, opts::Opts, sd::StepData,  k::Int64, gnum::Int64, origWant::Int64, fromOutputsFunction; outputLevel::Int64=0)

	longKey = problem.name*":"*problem.lossFunctionString*":"*string(problem.L2reg)*":"sd.stepString*":"*"const"*":"*string(opts.stepSizePower)
	
	if ~exists(client, longKey*":k")
		outputLevel>0 && println("Key doesn't exist, so pushing new")
		rpush(client, longKey*":k",k)
		rpush(client, longKey*":gnum",gnum)
		rpush(client, longKey*":origWant",origWant)
		for j in 1:length(fromOutputsFunction.resultLine)
			rpush(client, longKey*":$j",fromOutputsFunction.resultLine[j])
		end
	else
		arrayOfStrings  = lrange(client, longKey*":gnum", 0, -1)
		currentIndex=0
		for i in 1:length(arrayOfStrings)
			if gnum==int(arrayOfStrings[i])
				outputLevel>0 && println("Not writing because exists exact same with gnum = $gnum, at i = $i")
				ah = int(lindex(client,longKey*":origWant",i-1))
				if origWant < ah
					outputLevel>0 && println("origWant < ah, $origWant < $ah, so replacing!")
					lset(client, longKey*":origWant", i-1, origWant)
				end
				return
			end
			if int(arrayOfStrings[i])>gnum
				outputLevel>0 && println("Found where to insert: before $(i-1)")
				currentIndex=i-1
				break
			end
		end
		if currentIndex ==0
			outputLevel>0 && println("Didn't find where to insert, so attaching at the end")
			rpush(client, longKey*":k",k)
			rpush(client, longKey*":gnum",gnum)
			rpush(client, longKey*":origWant",origWant)
			for j in 1:length(fromOutputsFunction.resultLine)
				rpush(client, longKey*":$j",fromOutputsFunction.resultLine[j])
			end
		else
			ah = lindex(client,longKey*":k",currentIndex  )
			lset(client, longKey*":k", currentIndex, "oh well")
			linsert(client, longKey*":k" ,"after", "oh well" ,ah)
			linsert(client, longKey*":k" ,"after", "oh well" ,k)
			lrem(client, longKey*":k" ,0, "oh well")
			
			ah = lindex(client,longKey*":gnum",currentIndex  )
			lset(client, longKey*":gnum", currentIndex, "oh well")
			linsert(client, longKey*":gnum" ,"after", "oh well" ,ah)
			linsert(client, longKey*":gnum" ,"after", "oh well" ,gnum)
			lrem(client, longKey*":gnum" ,0, "oh well")
			
			ah = lindex(client,longKey*":origWant",currentIndex  )
			lset(client, longKey*":origWant", currentIndex, "oh well")
			linsert(client, longKey*":origWant" ,"after", "oh well" ,ah)
			linsert(client, longKey*":origWant" ,"after", "oh well" ,origWant)
			lrem(client, longKey*":origWant" ,0, "oh well")
			
			for j in 1:length(fromOutputsFunction.resultLine)
				ah = lindex(client,longKey*":$j",currentIndex  )
				lset(client, longKey*":$j", currentIndex, "oh well")
				linsert(client, longKey*":$j" ,"after", "oh well" ,ah)
				linsert(client, longKey*":$j" ,"after", "oh well" ,fromOutputsFunction.resultLine[j])
				lrem(client, longKey*":$j" ,0, "oh well")
			end
		end
	end
	# println(int(lrange(client, longKey*":gnum",0, -1)))
end