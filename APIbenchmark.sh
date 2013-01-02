#! /bin/bash

sleepTime=0
# do the overall test, this many times
for i in {1..1}
do
jobs=10000
    # 1 through 8 for the sleeptimes
    for k in {1..9}
    do
	echo "Jobs: $jobs    SleepTime: $sleepTime"
	(/usr/bin/time -f "%e" ./bin/APITest $jobs $sleepTime) 2>> logs/log$i.txt

	# double the matrix size
        jobs=$(($jobs+$jobs))
    done
#    sleepTime=$(($sleepTime+$sleepTime))
done