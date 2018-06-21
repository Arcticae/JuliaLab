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
