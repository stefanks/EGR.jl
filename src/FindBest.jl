function getF(res, glim)
	currentBest = Inf
	prevRunValue = Inf
	prevG = Inf
	for i in 1:size(res[4], 1)
		thisRunValue = res[4][i,1]
		if thisRunValue<currentBest && res[3][i]<=glim
			currentBest=thisRunValue
		end
		if res[3][i]>glim
			midValue  = thisRunValue + ((res[3][i]  - glim)/(res[3][i]-prevG))* (prevRunValue-thisRunValue)
			if midValue<currentBest
				currentBest=midValue
			end
			break
		end
		prevRunValue=thisRunValue
		prevG=res[3][i]
	end
	currentBest
end

function getFfinal(res, glim)
	currentBest = Inf
	for i in 1:size(res[4], 1)
		thisRunValue = res[4][i,1]
		if res[3][i]<=glim && ~isnan(thisRunValue)
			currentBest=thisRunValue
		end
		if res[3][i]>glim
			if  ~isnan(thisRunValue) && ~isinf(thisRunValue)
				currentBest = thisRunValue + ((res[3][i]  - glim)/(res[3][i]-prevG))* (prevRunValue-thisRunValue)
			end
			break
		end
		prevRunValue=thisRunValue
		prevG=res[3][i]
	end
	min(currentBest,res[4][1,1])
end

function getPCC(res, glim)
	currentBest = Inf
	for i in 1:size(res[4], 1)
		thisRunValue = -res[4][i,2]
		if thisRunValue<currentBest && res[3][i]<=glim
			currentBest=thisRunValue
		end
	end
	currentBest
end

function getMCC(res, glim)
	currentBest = Inf
	for i in 1:size(res[4], 1)
		thisRunValue = -res[4][i,3]
		if thisRunValue<currentBest && res[3][i]<=glim
			currentBest=thisRunValue
		end
	end
	currentBest
end

# FIND THE LOWEST VALUE!!! Therefore, valueComputer must return the negative of pcc and mcc
function findBestStepsizeFactor(alg::Function, getThisRunValue::Function, bestPossible::Float64, thisString, returnResultIfExists::Function; outputLevel::Int64=0)
	
	mid = 50
	
	outputLevel>0 && println("Starting findBestStepsizeFactor, with $(2*mid-1) possible stepsizes, looking for $thisString")
	
	function getNextI(values)
		
		outputLevel>2 && println(values)
		
		# Weird cases
		for i in values
			if i<=bestPossible
				return false
			end
		end
		
		
		# Find minimizer
		(bestVal, bestI) = findmin(values)
		
		possibleUp=0
		possibleDown=0
		prevUpValue=0
		prevDownValue=0
		checkUp=true
		for i in bestI:99
			outputLevel>2 && println("  Looking at i = $i values[i]=$(values[i])") 
			if isnan(values[i])
				outputLevel>1 && println(" Might look up! Prev = $(values[i-1]) ") 
				possibleUp=i
				prevUpValue= values[i-1]
				break
			elseif i<=97 && values[i]<=values[i+1]<=values[i+2]
				outputLevel>1 && println(" $(values[i]) $(values[i+1]) $(values[i+2])")
				checkUp = false
				break
			elseif i==98 && values[i]<values[i+1]
				outputLevel>1 && println(" $(values[i]) $(values[i+1])")
				checkUp = false
				break
			elseif i==99
				outputLevel>1 && println(" $(values[i])")
				checkUp = false
				break	
			end
		end
		
		checkDown=true
		for i in bestI:-1:1
			outputLevel>2 && println("  Looking at i = $i values[i]=$(values[i])") 
			if isnan(values[i])
				outputLevel>1 && println(" Might look down! Prev = $(values[i+1]) ") 
				possibleDown=i
				prevDownValue= values[i+1]
				break
			elseif i>=3 && values[i-2]>=values[i-1]>values[i]
				outputLevel>1 && println(" $(values[i-2]) $(values[i-1]) $(values[i])")
				checkDown = false
				break
			elseif i==2 && values[i-1]>values[i]
				outputLevel>1 && println(" $(values[i-1]) $(values[i])")
				checkDown = false
				break
			elseif i==1
				outputLevel>1 && println(" $(values[i])")
				checkDown = false
				break	
			end
		end
		
		if checkUp==false && checkDown==false
			return false
		elseif checkUp==false
			return possibleDown
		elseif checkDown==false
			return possibleUp
		else
			if prevDownValue<prevUpValue
				return possibleDown
			else
				return possibleUp
			end
		end
	end
	
	# The middle one corresponds to 1 (or to 2^0) !!
	values=ones(2*mid-1)*NaN
	
	# Always start with -20,-10,0,10

	if returnResultIfExists(-20)==false
		theValueS = getThisRunValue(alg(-20))
		values[mid-20] = theValueS
		outputLevel>1 && println(" For stepsizePower -20 the value is $theValueS")
	end
	if returnResultIfExists(-10)==false
		theValueA = getThisRunValue(alg(-10))
		values[mid-10] = theValueA
		outputLevel>1 && println(" For stepsizePower -10 the value is $theValueA")
	end
	if returnResultIfExists(0)==false
		theValueB = getThisRunValue(alg(0))
		values[mid] = theValueB
		outputLevel>1 && println(" For stepsizePower 0 the value is $theValueB")
	end
	if returnResultIfExists(10)==false
		theValueC = getThisRunValue(alg(10))
		values[mid+10] = theValueC
		outputLevel>1 && println(" For stepsizePower 10 the value is $theValueC")
	end
	
	bestI=0
	currentBest=Inf
	for i in 1:99
		existingResult = returnResultIfExists(i-mid)
		if existingResult != false
			values[i] = getThisRunValue(existingResult)
		end
		if values[i]<currentBest
			bestI = i
			currentBest = values[i]
		end
	end
	
	
	# New routine
	nextI = getNextI(values) 
	while nextI != false
		values[nextI] = getThisRunValue(alg(nextI-mid))
		nextI = getNextI(values)
	end

	(bestVal, bestI) = findmin(values)
	outputLevel>0 && println("Best stepsize power found: $(bestI-mid)")
	outputLevel>0 && println("Best value found: $bestVal")
	((bestI-mid), bestVal) 
end