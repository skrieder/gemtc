#! /bin/bash
threads=1

for c in {1..2}
do
sleepTime=8

for i in {1..7}
do

    jobs=1000
    for k in {1..7}
    do
	echo "Threads: $threads    Jobs: $jobs    SleepTime: $sleepTime"
	(/usr/bin/time -f "%e" ../../bin/APIThread $threads $jobs $sleepTime 4 1000) 2>> ../../logs/logAPIThreadTest$c.txt

        jobs=$(($jobs+$jobs))
    done
    sleepTime=$(($sleepTime+$sleepTime))
done

done