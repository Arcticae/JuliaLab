function producer(c::Channel)
    put!(c,"start")
    for i = 1:10
        put!(c,i)
    end
    put!(c,"stop")
end

channellol=Channel(producer)    #defines task bound to the channel

take!(channellol)

for x in Channel(producer)
    print(x," ")
end

function det_task(size)
    det(rand(size,size))
end

taskCheat=(()->det_task(100))
#or a macro
taskCheat2 = @task det_task(100)
istaskstarted(taskCheat2)

schedule(taskCheat2)

fieldnames(taskCheat2)
print(taskCheat2.storage)


##------------simple producer consumer like on SYSOPAS d-.-b ----------------####

l = ReentrantLock()
@sync for i in 1:3
    @async begin
        lock(l)
        try
            print("Zadanie $i\n")
            sleep(rand()*0.2)
            print("($i) etap 1 \n")
            sleep(rand()*0.2)
            print("($i) etap 2\n")
        finally
            unlock(l)
        end
    end
end
print("Główne zadanie\n")


addprocs(3)

nprocs() |> println
workers() |> println
nworkers() |> println

futur=remotecall(myid,workers()[1])
fetch(futur)
remotecall(myid,workers()[1])

cod=remotecall(()->rand(2,2),2) #fun,id,args
cod2=@spawnat 3 fetch(cod)  #spawn fetch from previous on id 3
fetch(cod2)     #fetch the fetch
fetch(cod)


###--------ZAD1--------####
last=0
function print_in_order(arg::Int64,repetitions::Int64)
    for i = 1:repetitions
        while((last)% 3 + 1 != arg)
            yield()
        end
        print(arg,'\n')
        global last=arg
    end end

@everywhere function fundef(args...)
    print(args...)end


t1=@task print_in_order(1,5)
t2=@task print_in_order(2,5)
t3=@task print_in_order(3,5)
schedule(t3)
schedule(t2)
schedule(t1)
