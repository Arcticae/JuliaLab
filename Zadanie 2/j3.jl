import Base.^
import Base.*
import Base.convert
import Base.promote_rule

function print_derivative(x)
    if(isa(x,Type{Any}))
        return x
    end
    return string(print_derivative(supertype(x)),"-->",x) end

print_derivative(UInt128)

struct Gn{N}
    x::Number
    Gn{N}(x) where N=new(findMember(x,N))
end
function findMember(x,N)
    if(x>=N)
        x=x%N
    end
    if(x>0 && gcd(x,N)!=1) #greatest common divisor must be 1 to be valid
        throw(DomainError)
    end

    return x end
Gn{10}(43)

function *(A::Gn{N},B::Gn{N}) where N
    return Gn{N}(A.x*B.x)
end

Gn{10}(3)*Gn{10}(7)

function *(A::Gn{N},B::Integer) where N
    return Gn{N}(A.x*B)
end

function *(B::Integer,A::Gn{N}) where N
    return A*B
end

convert(::Type{Gn{N}},x::Int64) where N = Gn{N}(x)
convert(::Type{Int64},x::Gn{N}) where N = x.x

promote_rule(::Type{Gn{N}},::Type{T}) where {T<:Integer,N} = Gn{N}

function ^(A::Gn{N},B::Integer) where N
    x=Gn{N}(1)
    for i=1:B
        x=x*A       #new object is created every time there is multiplication of Gn{N}*Gn{n}
    end
    return x
end

function period(A::Gn{N}) where N #a^r mod N ==1 smallest natyral r
    for i=1:N
        if ((A^i).x==1)
            return i
        end
    end
    throw(DomainError())
end


period(Gn{1000}(7))

function reverse_element(A::Gn{N}) where N #a*r mod N ==1 smallest natyral r
    for i=1:N
        try
            if ((A*i).x==1)
                return i
            end
        catch e
        end
    end
end


reverse_element(Gn{1000}(7))

function counter(T::Type{Gn{N}}) where N
    len=0
    for i=1:N
        try
        if((Gn{N}(i)).x==i)
            len+=1
        end
        catch e
        end

    end
    return len end
counter(Gn{6})



okres_r=period(Gn{55}(4))

d=reverse_element(Gn{okres_r}(17))

a=(4^d)%55

4 == (a^17)%55
