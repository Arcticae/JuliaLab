function swap!(x::Array{Int64},a::Int64,b::Int64)

  tmp=x[a]
  x[a]=x[b]
  x[b]=tmp
  return x

  end

  function bubblesort!(x::Array{Int64})

      for i in 2:length(x)
          for j in 1:length(x)-1
              if x[j]>x[j+1]
                  swap(x,j,j+1)
              end
          end
      end
      return x
  end

  x=[10,6,8,9,6,4,3,7,9,0]

x=bubblesort(x)
