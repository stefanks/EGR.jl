function getF(res, glim)
	currentBest = Inf
	for i in 1:size(res[4], 1)
		thisRunValue = res[4][i,1]
		if thisRunValue<currentBest && res[3][i]<=glim
			currentBest=thisRunValue
		end
	end
	currentBest
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
function findBestStepsizeFactor(alg::Function, getThisRunValue::Function, bestPossible::Float64; outputLevel::Int64=0)
	
	mid = 50
	
	outputLevel>0 && println("Starting findBestStepsizeFactor, with $(2*mid-1) possible stepsizes")
	
	function checkValues(values, checkDown, checkUp,lowestImprov)
		
		if ~isnan(values[1]) 
			checkDown = false
		end
		if ~isnan(values[end]) 
			checkUp = false
		end
		
		for i in values
			if i==bestPossible
				return (false, false)
			end
		end
		
		
		# Find minimizer
		(bestVal, bestI) = findmin(values)
		if checkDown ==true
			for i in 1:length(values)-2
				if i+2>bestI
					break
				end
				if values[i]>=values[i+1]>values[i+2]
					outputLevel>1 && println("$(values[i]) $(values[i+1]) $(values[i+2])")
					checkDown = false
					break
				end
			end
		end
		
		# Search for UP sequence
		if checkUp ==true
			for j in bestI:length(values)-2
				if values[j]<values[j+1]<=values[j+2]
					outputLevel>1 && println("$(values[j]) $(values[j+1]) $(values[j+2])")
					checkUp = false
					break
				end
			end
		end
		
		for i in 1:length(values)-2
			if values[i]==values[i+1]==values[i+2]
				checkUp = false
			end
		end

		# But maybe still need to go lower?
		if lowestImprov==false
			checkDown=true
		end
		for i in 2:length(values)-2
			if i+2>bestI
				break
			end
			if (values[i]<values[i+1] && isnan(values[i-1])) ||  (values[i+1]<values[i+2] && isnan(values[i-1]))
				checkDown = true
				break
			end
		end
		
		return (checkDown, checkUp)
	end
	
	# The middle one corresponds to 1 (or to 2^0) !!
	values=ones(2*mid-1)*NaN
	startValue = NaN
	
	# Always start with zero power

	theValue = getThisRunValue(alg(0))
	outputLevel>1 && println("For stepsizePower 0 the value is $theValue")
	values[mid] = theValue
	
	currentIup = mid+1
	currentIdown = mid-1
	checkDown, checkUp = true, true
	lowestImprov=false
	(checkDown, checkUp) = checkValues(values, checkDown, checkUp,lowestImprov)
	while (checkDown, checkUp) != (false, false)
		if  checkDown==true
			outputLevel>1 && println("Exploring down!")
			stepsizePower = currentIdown-mid
			res=alg(stepsizePower)
			theValue = getThisRunValue(res)
			outputLevel>1 && println("For stepsizePower $stepsizePower the value is $theValue")
			values[currentIdown] = theValue
			currentIdown -= 1
			if res[4][end,end]<res[4][1,end]
				lowestImprov = true
			end
			(checkDown, checkUp) = checkValues(values, checkDown, checkUp,lowestImprov)
			outputLevel>1 && println((checkDown, checkUp))
		end
		if  checkUp==true
			outputLevel>1 && println("Exploring up!")
			stepsizePower = currentIup-mid
			theValue = getThisRunValue(alg(stepsizePower))
			outputLevel>1 && println("For stepsizePower $stepsizePower the value is $theValue")
			values[currentIup] = theValue
			currentIup += 1
			(checkDown, checkUp) = checkValues(values, checkDown, checkUp, lowestImprov)
			outputLevel>1 && println((checkDown, checkUp))
		end
	end

	(bestVal, bestI) = findmin(values)
	outputLevel>0 && println("Best stepsize power found: $(bestI-mid)")
	outputLevel>0 && println("Best value found: $bestVal")
end