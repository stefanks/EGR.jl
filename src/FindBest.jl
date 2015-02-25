function findBestStepsizeFactor(whatWeCareAbout::String, alg::Function; outputLevel::Int64=0)
	
	mid = 50
	
	outputLevel>0 && println("Starting findBestStepsizeFactor, with $(2*mid-1) possible stepsizes")
	
	function getThisRunValue(res)
		currentBest = Inf
		# println("getting the run value")
		for i in 1:size(res[4], 1)
			if whatWeCareAbout == "f"
				thisRunValue = res[4][i,1]
			elseif whatWeCareAbout == "pcc"
				thisRunValue = -res[4][i,2]
			else
				error(whatWeCareAbout*" is not an option")
			end
			# println(res)
			# println(res[4])
			# println(res[4][i])
			# println(res[4][i][2][1])
			# println(res[4][i][2][2])
			# println(thisRunValue)
			if thisRunValue<currentBest
				currentBest=thisRunValue
			end
		end
		currentBest
	end
	
	function checkValues(values, whatWeCareAbout, startValue, checkDown, checkUp)
		
		if whatWeCareAbout == "f" 
			bestPossible = 0.0
			worstPossible = Inf
		elseif whatWeCareAbout == "pcc" 
			bestPossible = -1.0
			worstPossible = 0.0
		end
		
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
		
		
		
		## Search for good start sequence!
		for i in 1:length(values)-2
			if values[i]>=values[i+1]>values[i+2]
				checkDown = false
				## Search for the end sequence!
				for j in i+2:length(values)-2
					if values[j]<values[j+1]<=values[j+2]
						outputLevel>1 && println("$(values[i]) $(values[i+1]) $(values[i+2]) $(values[j]) $(values[j+1]) $(values[j+2])")
						return (false, false)
					end
				end
			end
			if values[i]==values[i+1]==values[i+2]
				checkUp = false
			end
		end

		return (checkDown, checkUp)
	end
	
	# The middle one corresponds to 1 (or to 2^0) !!
	values=ones(2*mid-1)*NaN
	startValue = NaN
	
	# Always start with zero power

	stepsizePower = 0
	res = alg(0)
	if whatWeCareAbout == "f"
		startValue = res[4][1,1]
	elseif whatWeCareAbout == "pcc"
		startValue = -res[4][1,2]
		end
	theValue = getThisRunValue(res)
	outputLevel>1 && println("For stepsizePower 0 the value is $theValue")
	values[mid] = theValue
	
	currentIup = mid+1
	currentIdown = mid-1
	checkDown=true
	checkUp=true
	(checkDown, checkUp) = checkValues(values, whatWeCareAbout, startValue, checkDown, checkUp)
	while (checkDown, checkUp) != (false, false)
		if  checkDown==true
			outputLevel>1 && println("Exploring down!")
			stepsizePower = currentIdown-mid
			theValue = getThisRunValue(alg(stepsizePower))
			outputLevel>1 && println("For stepsizePower $stepsizePower the value is $theValue")
			values[currentIdown] = theValue
			currentIdown -= 1
			(checkDown, checkUp) = checkValues(values, whatWeCareAbout, startValue, checkDown, checkUp)
			outputLevel>1 && println((checkDown, checkUp))
		end
		if  checkUp==true
			outputLevel>1 && println("Exploring up!")
			stepsizePower = currentIup-mid
			theValue = getThisRunValue(alg(stepsizePower))
			outputLevel>1 && println("For stepsizePower $stepsizePower the value is $theValue")
			values[currentIup] = theValue
			currentIup += 1
			(checkDown, checkUp) = checkValues(values, whatWeCareAbout, startValue, checkDown, checkUp)
			outputLevel>1 && println((checkDown, checkUp))
		end
	end

	(bestVal, bestI) = findmin(values)
	outputLevel>0 && println("Best stepsize power found: $(bestI-mid)")
	if whatWeCareAbout == "f" 
		myval = bestVal
	elseif whatWeCareAbout == "pcc" 
		myval = -bestVal
	end
	outputLevel>0 && println("Best $whatWeCareAbout found: $myval")
	(bestI-mid, myval)
end