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

function getFfinal(res, glim)
	currentBest = Inf
	for i in 1:size(res[4], 1)
		thisRunValue = res[4][i,1]
		if res[3][i]<=glim
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
function findBestStepsizeFactor(alg::Function, getThisRunValue::Function, bestPossible::Float64, thisString; outputLevel::Int64=0)
	
	mid = 50
	
	outputLevel>0 && println("Starting findBestStepsizeFactor, with $(2*mid-1) possible stepsizes, looking for $thisString")
	
	function checkValues(values, checkDown, checkUp,lowestImprov)
		
		
		for i in values
			if i<=bestPossible
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
					outputLevel>1 && println(" $(values[i]) $(values[i+1]) $(values[i+2])")
					checkDown = false
					break
				end
			end
		end
		
		# Search for UP sequence
		if checkUp ==true
			for j in bestI:length(values)-2
				if values[j]<values[j+1]<=values[j+2]
					outputLevel>1 && println(" $(values[j]) $(values[j+1]) $(values[j+2])")
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
		
		if ~isnan(values[1]) 
			checkDown = false
		end
		if ~isnan(values[end]) 
			checkUp = false
		end
		
		
		return (checkDown, checkUp)
	end
	
	# The middle one corresponds to 1 (or to 2^0) !!
	values=ones(2*mid-1)*NaN
	
	# Always start with -20,-10,0,10

	theValueS = getThisRunValue(alg(-20))
	values[mid-20] = theValueS
	outputLevel>1 && println(" For stepsizePower -20 the value is $theValueS")
	theValueA = getThisRunValue(alg(-10))
	values[mid-10] = theValueA
	outputLevel>1 && println(" For stepsizePower -10 the value is $theValueA")
	theValueB = getThisRunValue(alg(0))
	values[mid-10] = theValueB
	outputLevel>1 && println(" For stepsizePower 0 the value is $theValueB")
	theValueC = getThisRunValue(alg(10))
	values[mid+10] = theValueC
	outputLevel>1 && println(" For stepsizePower 10 the value is $theValueC")
	if theValueA<=theValueB && theValueA<=theValueC && theValueA<=theValueS
		currentIup = mid+1-10
		currentIdown = mid-1-10
	elseif theValueB<=theValueA && theValueB<=theValueC && theValueB<=theValueS
		currentIup = mid+1
		currentIdown = mid-1
	elseif theValueC<=theValueB && theValueC<=theValueA && theValueC<=theValueS
		currentIup = mid+1+10
		currentIdown = mid-1+10
	elseif theValueS<=theValueB && theValueS<=theValueA && theValueS<=theValueC
		currentIup = mid+1-20
		currentIdown = mid-1-20
	end
	
	checkDown, checkUp = true, true
	lowestImprov=false
	(checkDown, checkUp) = checkValues(values, checkDown, checkUp,lowestImprov)
	while (checkDown, checkUp) != (false, false)
		if  checkDown==true
			outputLevel>1 && println(" Looking at next down!")
			stepsizePower = currentIdown-mid
			res=alg(stepsizePower)
			theValue = getThisRunValue(res)
			outputLevel>1 && println(" For stepsizePower $stepsizePower the value is $theValue")
			values[currentIdown] = theValue
			currentIdown -= 1
			if res[4][end,end]<res[4][1,end]
				lowestImprov = true
			end
			(checkDown, checkUp) = checkValues(values, checkDown, checkUp,lowestImprov)
			outputLevel>1 && println(" $((checkDown, checkUp))")
		end
		if  checkUp==true
			outputLevel>1 && println(" Looking at next up!")
			stepsizePower = currentIup-mid
			theValue = getThisRunValue(alg(stepsizePower))
			outputLevel>1 && println(" For stepsizePower $stepsizePower the value is $theValue")
			values[currentIup] = theValue
			currentIup += 1
			(checkDown, checkUp) = checkValues(values, checkDown, checkUp, lowestImprov)
			outputLevel>1 && println(" $((checkDown, checkUp))")
		end
	end

	(bestVal, bestI) = findmin(values)
	outputLevel>0 && println("Best stepsize power found: $(bestI-mid)")
	outputLevel>0 && println("Best value found: $bestVal")
	((bestI-mid), bestVal) 
end