Pkg.add("Gadfly")
Pkg.add("DataFrames")
Pkg.add("DifferentialEquations")
Pkg.update()

using DataFrames
using Gadfly
using DifferentialEquations
#set defaults
Gadfly.push_theme(:default)

#Zadanie 1
function lotkavolter( a, b, c, d, x0, y0, filename,experiment_no )
    #inner function defining behaviour of prey and predator with lotka-volter model
    #(du1=dx/dt)(du2=dy/dt)(u->variables u[1] -> x u[2] ->y)
    function lv_equation(du,u,p,t)  #p(parameters) are unused because of the scope of our variables abcd
        du[1]= (a*u[1]) - (b*u[1]*u[2])
        du[2]= (-c*u[2]) + (d*u[1]*u[2])
    end

    tspan=(0.0,20.0)        #span of time
    u0_point=[x0,y0]        #starting conditions for variable 'U' -> (x,y)

    task= ODEProblem(lv_equation,u0_point,tspan)
    solution = solve(task,RK4())  #we can modify dt if we want

    #now we need to add the solution to some kind of csv file (filename,experiment)
    i=1
    solutionX=[]
    solutionY=[]
    while(i<=length(solution.t))
        push!(solutionX,solution.u[i][1])
        push!(solutionY,solution.u[i][2])
        i+=1
    end

    dataframe_resultX=DataFrame(t=solution.t,u=solutionX)
    dataframe_resultY=DataFrame(t=solution.t,u=solutionY)

    #print(dataframe_resultX)
    #print(dataframe_resultY)

    #now save the results to csv

    result=hcat(solution.t,solutionX,solutionY,fill("exp$(experiment_no)",length(solution.t)))

    #print(result)
    writedlm(filename, result ,';')
    return solution end

#plot(dataframe_resultX,x="t",y="u")
#plot(dataframe_resultY,x="t",y="u")

sol1=lotkavolter(1,1,1,1,2.0,4.0,"./res1.csv",1)
sol2=lotkavolter(1,3,5,7,2.0,4.0,"./res2.csv",2)
sol3=lotkavolter(4,6,2,10,2.0,4.0,"./res3.csv",3)
sol4=lotkavolter(12,14,18,13,2.0,4.0,"./res4.csv",4)


#Zadanie 2

exp1=readdlm("res1.csv",';',Any,'\n',header=false)
exp2=readdlm("res2.csv",';',Any,'\n',header=false)
exp3=readdlm("res3.csv",';',Any,'\n',header=false)
exp4=readdlm("res4.csv",';',Any,'\n',header=false)

final=vcat(exp1,exp2,exp3,exp4)

#x->prey y->predator
#final
quantity_difference=(final[:,3]-final[:,2])

#print(quantity_difference)
concat_dataframe=DataFrame(t=final[:,1],x=final[:,2],y=final[:,3],diff=quantity_difference,exp_nr=final[:,4])
concat_dataframe
len=size(concat_dataframe)[1]

for exp in ["exp1","exp2","exp3","exp4"]
    preds=[]
    prey=[]
    diff=[]
    for i = 1:len
        if exp==concat_dataframe[i,5]
            push!(preds,concat_dataframe[i,3])
            push!(prey,concat_dataframe[i,2])
            push!(diff,concat_dataframe[i,4])
        end
    end

    println("Stats on ",exp)
    println("AVG predators: ",mean(preds))
    println("Min predators: ",minimum(preds))
    println("Max predators: ",maximum(preds))

    println("")
    println("AVG prey: ",mean(prey))
    println("Min prey: ",minimum(prey))
    println("Max prey: ",maximum(prey))
    println("")
    println("Min diff: ",minimum(diff))
    println("Max diff: ",maximum(diff))
    println("----------------------------------------")
end


sol1_x=[]
sol1_y=[]
diff1=[]

for i = 1 : length(sol1.u)
    push!(sol1_x,sol1.u[i][1])
    push!(sol1_y,sol1.u[i][2])
    push!(diff1,sol1.u[i][1]-sol1.u[i][2])
end

dataframe1_sol_x=DataFrame(t=sol1.t,u=sol1_y)
dataframe1_sol_y=DataFrame(t=sol1.t,u=sol1_x)
dataframe1_diff=DataFrame(t=sol1.t,u=diff1)
plot(layer(dataframe1_sol_x,x="t",y="u",Geom.line,Theme(default_color="blue")),layer(dataframe1_sol_y,x="t",y="u",Geom.line,Theme(default_color="red")),Guide.title("exp1")))

joined_dataframe=DataFrame(dt=sol1.t,dx=sol1_x,dy=sol1_y)

widedf=DataFrame(time=sol1.t, prey=sol1_x, predators=sol1_y)
longdf=stack(widedf, 2:3)
plot(longdf, ygroup="variable", x="time", y="value", Geom.subplot_grid(Geom.line))

plot(widedf,x="prey",y="predators",Geom.path)
