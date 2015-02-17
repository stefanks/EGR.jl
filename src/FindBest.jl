function findBestStepsizeFactor(whatWeCareAbout::String, origStepsize::Function, alg::Function; outputLevel::Int64=0)
	
	mid = 50
	
	function getThisRunValue(res)
		
		if whatWeCareAbout == "f"
			thisRunValue = res[1]
		elseif whatWeCareAbout == "pcc"
			thisRunValue = -res[2]
		else
			error(whatWeCareAbout*" is not an option")
		end
		thisRunValue
	end
	
	function checkValues(values, whatWeCareAbout)
		# println(values)
		for i in 1:2*mid-3
			if values[i]>=values[i+1]>values[i+2]
				for j in i+2:2*mid-3
					if values[j]<values[j+1]<=values[j+2]
						outputLevel>1 && println("$(values[i]) $(values[i+1]) $(values[i+2]) $(values[j]) $(values[j+1]) $(values[j+2])")
						return true
					end
				end
			end
		end
		if whatWeCareAbout == "pcc" && minimum(values) == -1.0
			return true
		end
		return false
	end
	
	# The middle one corresponds to 1 (or to 2^0) !!
	values=ones(2*mid-1)*NaN
	
	# Always start with 0.5,1,2
	
	for currentI in [mid-1,mid,mid+1]
		stepsize(k) = 2.0^(currentI-mid) * origStepsize(k)
		theValue = getThisRunValue(alg(stepsize))
		outputLevel>1 && println("For index $currentI the value is $theValue")
		values[currentI] = theValue
	end
	
	# For sure explore down!
	if (values[mid-1]<values[mid]<=values[mid+1]) ||(isinf(values[mid-1]) && isinf(values[mid]) && isinf(values[mid+1]) )
		outputLevel>1 && println("Exploring down!")
		currentI=mid-2
		while true
			stepsize(k) = 2.0^(currentI-mid) * origStepsize(k)
			theValue = getThisRunValue(alg(stepsize))
			outputLevel>1 && println("For index $currentI the value is $theValue")
			values[currentI] = theValue
			if checkValues(values, whatWeCareAbout) == true
				outputLevel>1 && println("Found the best step!")
				break
			end
			currentI-=1
			if ~isinf(maximum(values)) && maximum(values) == minimum(values)
				outputLevel>1 && println("~isinf(maximum(values)) && maximum(values) == minimum(values)")
				outputLevel>1 && println("Quitting!")
				break
			end
			if currentI<1 || currentI>length(values)
				outputLevel>1 && println("currentI = $currentI")
				outputLevel>1 && println("currentI<1 || currentI>length(values)")
				outputLevel>1 && println("Quitting!")
				break
			end
		end
	elseif values[mid-1]>=values[mid]>values[mid+1]
		outputLevel>1 && println("Exploring up!")
		currentI=mid+2
		while true
			stepsize(k) = 2.0^(currentI-mid) * origStepsize(k)
			theValue = getThisRunValue(alg(stepsize))
			outputLevel>1 && println("For index $currentI the value is $theValue")
			values[currentI] = theValue
			if checkValues(values, whatWeCareAbout) == true
				outputLevel>1 && println("Found the best step!")
				break
			end
			currentI+=1
			if ~isinf(maximum(values)) && maximum(values) == minimum(values)
				outputLevel>1 && println("~isinf(maximum(values)) && maximum(values) == minimum(values)")
				outputLevel>1 && println("Quitting!")
				break
			end
			if currentI<1 || currentI>length(values)
				outputLevel>1 && println("currentI = $currentI")
				outputLevel>1 && println("currentI<1 || currentI>length(values)")
				outputLevel>1 && println("Quitting!")
				break
			end
		end
	else
		outputLevel>1 && println("Exploring both up and down!")
		currentIup=mid+2
		currentIdown=mid-2
		exploreDown  = true
		exploreUp  = true
		while true
			if exploreUp  == true
				stepsize(k) = 2.0^(currentIup-mid) * origStepsize(k)
				theValue = getThisRunValue(alg(stepsize))
				outputLevel>1 && println("For index $currentIup the value is $theValue")
				values[currentIup] = theValue
				if checkValues(values, whatWeCareAbout) == true
					outputLevel>1 && println("Found the best step!")
					break
				end
				if values[currentIup-2]<values[currentIup-1]<=values[currentIup]
					outputLevel>1 && println("$(values[currentIup-2]) $(values[currentIup-1]) $(values[currentIup])")
					outputLevel>1 && println("exploreUp=false")
					exploreUp=false
				end
				currentIup+=1
			end
			if exploreDown ==true
				stepsize(k) = 2.0^(currentIdown-mid) * origStepsize(k)
				theValue = getThisRunValue(alg(stepsize))
				outputLevel>1 && println("For index $currentIdown the value is $theValue")
				values[currentIdown] = theValue
				if checkValues(values, whatWeCareAbout) == true
					outputLevel>1 && println("Found the best step!")
					break
				end
				if values[currentIdown]>=values[currentIdown+1]>values[currentIdown+2]
					outputLevel>1 && println("$(values[currentIdown]) $(values[currentIdown+1]) $(values[currentIdown+2])")
					outputLevel>1 && println("exploreDown=false")
					exploreDown=false
				end
				currentIdown-=1
			end
			if ~isinf(maximum(values)) && maximum(values) == minimum(values)
				outputLevel>1 && println("~isinf(maximum(values)) && maximum(values) == minimum(values)")
				outputLevel>1 && println("Quitting!")
				break
			end
			if currentIdown<1 || currentIup>length(values)
				outputLevel>1 && println("currentI = $currentI")
				outputLevel>1 && println("currentI<1 || currentI>length(values)")
				outputLevel>1 && println("Quitting!")
				break
			end
		end
	end
	(bestVal, bestI) = findmin(values)
	outputLevel>0 && println("Best index is: $bestI")
	outputLevel>0 && println("Best stepsize found: 2^($(bestI-mid)) = $(2.0^(bestI-mid))")
	if whatWeCareAbout == "f" 
		 myval = bestVal
	 elseif whatWeCareAbout == "pcc" 
		 myval = -bestVal
	 end
	outputLevel>0 && println("Best $whatWeCareAbout found: $myval")
	(bestI, 2.0^(bestI-mid), myval)
end