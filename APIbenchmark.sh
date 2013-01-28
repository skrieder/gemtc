#! /bin/bash

sleepTime=0
threads=1

for c in {1..4}
do

for i in {1..6}
do
jobs=10000
    for k in $(eval echo {$i..8})
#    for k in {$i..9)}
    do
	echo "Threads: $threads    Jobs: $jobs    SleepTime: $sleepTime"
	(/usr/bin/time -f "%e" ./bin/APIThread $threads $jobs $sleepTime) 2>> logs/logAPIThreadTest$c.txt

        jobs=$(($jobs+$jobs))
    done
    threads=$(($threads+$threads))
#    sleepTime=$(($sleepTime+$sleepTime))
done

done