import Base.length

immutable MinusPlusOneVector
	field  :: Vector{Float64}
	numPlus :: Int64
	function MinusPlusOneVector{T}(inputfield::Vector{T})
		floatfield=ones(size(inputfield))
		numPlus=0
		for i = 1 : Base.size(inputfield)[1]
			if inputfield[i]==one(T)
				numPlus+=1
			elseif inputfield[i]==-one(T)
				floatfield[i] = -1
			else
				error("Not 1 or -1")
			end
		end
		new(floatfield,numPlus)
	end
	function MinusPlusOneVector(floatfield::Vector{Float64})
		numPlus=0
		for i in floatfield
			if i == one(Float64)
				numPlus+=1
			elseif i == -one(Float64)
			else
				error("Not 1 or -1")
			end
		end
		new(floatfield,numPlus)
	end
end

function MinusPlusOneVector{T}(fieldOfT::Vector{T},onesCollection::Set{T})
	floatfield=ones(size(fieldOfT))
	for i in 1 : size(fieldOfT)[1]
		if ! in(fieldOfT[i],onesCollection)
			floatfield[i]=-1
		end
	end
	MinusPlusOneVector(floatfield)
end

# These are used because they get imported by default !
function getindex(a::MinusPlusOneVector, b::UnitRange{Int64})
	getindex(a.field,b)
end
function getindex(a::MinusPlusOneVector, b::Int64)
	getindex(a.field,b)
end
function getindex(a::MinusPlusOneVector, b::Array{Int64,1})
	getindex(a.field,b)
end

function length(a::MinusPlusOneVector)
	length(a.field)
end
