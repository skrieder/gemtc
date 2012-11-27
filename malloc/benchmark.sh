#! /bin/bash 

#Sleep Time is currently not used            
sleepTime=10


# do the overall test, this many times
for i in {1..3}
do
    mallocs=2
    for k in {1..24}
    do
        echo $mallocs
	(/usr/bin/time -f "%e" ./mallocTest $mallocs) 2>> log.txt

        mallocs=$(($mallocs+$mallocs))
    done
done
