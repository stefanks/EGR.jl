println("some benchmarking")

i=10
j=50
k=5
maxIter=1000
indices = shuffle([1 : i])[1:k]

a=rand(i,j)

b=a[indices,:]

c=copy(b)

tic()
for iter=1:maxIter
	b*rand(j)
end
toc()

tic()
for iter=1:maxIter
	c*rand(j)
end
toc()




tic()
for iter=1:maxIter
	rand(k)'*b
end
toc()

tic()
for iter=1:maxIter
	rand(k)'*c
end
toc()