ex = quote
    x=1
    y=2
    x+y
end

#this is the same as...

ex=:(begin
    x=1
    y=3
    x+y
end)

eval(ex)                #evaluation
Meta.show_sexpr(ex)     #this is line by line dump
dump(ex)        #tree view, exprs.

a=2

ex=:($a+b)
dump(ex)

eval(ex)
b=3
eval(ex)

function math_eval(operator,operand1,operand2)
    expr_evaluation = Expr(:call,operator,operand1,operand2)
    return expr_evaluation
end

expr=math_eval(:+,1,Expr(:call,:*,4,5))
eval(expr)

macro sayhello(arg1,arg2)
    return :(println("Hello, ", $arg1," and ",$arg2))
end

You=1
#eeee wtf
@sayhello("You","idiot")
@sayhello "You" "idiot"
#equivalents

macroexpand(:(@sayhello(You,idiot)))

macro showarg(x)
    show(x)
end

@showarg(1+2)
@showarg(:println("no hejka"))

macro twostep(argument)
    println("I exec at the parsetime ", argument)
    return :(println("I exec at the runtime ", $argument))
end

@twostep(:(1,2,3))
@twostep((1,2,3))

ex= macroexpand( :(@twostep :(1,2,3)) )
eval(ex)

macro myassertion(expression)
    return :($expression ? nothing : error("assertion failed: ", $string(expression)))
end

macro assertcustom(ex,msgs...)
    msg_body = isempty(msgs) ? ex : msgs[1]
    msg=string(msg_body)
    return :($ex ? nothing : throw(AssertionError($msg)))
end

@assertcustom(1==1)
macroexpand(:(@assertcustom:("someexpr")))

macro time2(epx)
    return quote
      local t0=time()
      local evaluation =  $epx
      local t1 =time()
      println("Elapsed :" ,t1-t0)
      evaluation
    end
end

macroexpand(:(@time2 1==2))


@time2 1==2

macro g(y)
    :((x, $y, $(esc(y))))
end

x = 1
function t()
    x = 2
    println(macroexpand(:(@g(x))))
    println(@g(x))
end

t()
println(x)

function poly_horner(x, a...)
    b=zero(x)
    for i= length(a):-1:1
        println(i)
    end
    return b
end

poly_horner(x,1,2,3,4,5)

function prod_dim{T, N}(x::Array{T,N})
     s=1
    for i = 1:N
        s= s* size(x,i)
    end
    return s
end

@generated function prod_dim_gen{T,N}(x::Array{T,N})
    expresion = :(1)
    for i =1:N
        expresion = :(size(x,$i)*$expresion)
        print(expresion,"|")
    end
    return expresion
end

prod_dim_gen(A1)

function prod_dim_gen_impl{T,N}(x::Array{T,N})
    expresion = :(1)
    for i =1:N
        expresion = :(size(x,$i)*$expresion)
    end
    return expresion
end

prod_dim_gen_impl(A1)

A1

#function autodiff(ex::Expr)::Expr   #takes expr and returns exprs

#-------------------------------ZAD1---------------------------------#

function harmonic_avg_expresion(elems...) #gets a list of args
    n = length(elems) ##number of elements
    expresion = :(0)
    for i = 1:n
        expresion = :(1/elems[$i] + $expresion) ##nominative
    end
    expresion = :($n / $expresion)
    return expresion
end

harmonic_avg_expresion(1,2,3,4,5,6,7,8)

@generated function harmonic_avg(elems...)
    n = length(elems) ##number of elements
    expresion = :(0)
    for i = 1:n
        expresion = :(1/elems[$i] + $expresion) ##nominative
    end
    expresion = :($n / $expresion)
    return expresion
end

harmonic_avg(1,2,3,4,5,6,7,8)


#-------------------------------ZAD2---------------------------------#
function autodiff(ex::Expr)::Expr
    print("a ",ex.args,"\n")
    if length(ex.args)<=3
        return autodiff(ex.args[1],ex.args[2:end])  ##operand arg arg scheme
    else
        return autodiff(Expr(:call,ex.args[1],Expr(:call,ex.args[1],ex.args[2:end-1]...),ex.args[end]))
    end
end
function autodiff(ex::Number)::Int64  ## derivative of a constant = 0
    print("c ",ex,"\n")
    return 0
end

function autodiff(ex::Symbol)::Int64  ## derivative of a symbol?
    print("d ",ex,"\n")
    return :(1)
end

function autodiff(op::Symbol,args)::Expr    ## operator is a symbol, then two args.
    print("b ",args,"\n")
    if op==:*
        return Expr(:call,:+,Expr(:call,:*,autodiff(args[1]),args[2]),Expr(:call,:*,args[1],autodiff(args[2]))) ##wzór na pochodna iloczynu
    elseif op==:+
        return Expr(:call,:+,autodiff(args[1]),autodiff(args[2]))
    elseif op==:-
        return Expr(:call,:-,autodiff(args[1]),autodiff(args[2]))
    elseif op==:/
        nomin=Expr(:call,:-,Expr(:call,:*,autodiff(args[1]),args[2]),Expr(:call,:*,args[1],autodiff(args[2]))) #wzór na pochodną ilorazu
        denom=Expr(:call,:^,args[2],2)
        return Expr(:call,:/,nomin,denom)
    end
    return :()
end
func=:((5*x*x+ 4*x)/(3*x*x*x+2*x*x +x)+1)
x=5
eval(autodiff(func))
