function Generate10dpProblem()
	features = 
	[-1  1
	-1 -1
	-1 -2
	-1 -3
	1 -1
	-2 -2
	1  1
	-2 -3 
	-0.9 -0.9
	-1.1 -2.1]
			
	labels=[1,1,-1,-1,1,-1, 1, -1, 1, -1]
	setOfOnes=Set([1])
	
	createOracles(features,labels,2,10,setOfOnes; L2reg=false,outputLevel=0)
end