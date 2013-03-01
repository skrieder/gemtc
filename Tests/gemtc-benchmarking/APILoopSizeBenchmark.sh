#! /bin/bash

sleepTime=1000
threads=1
memSize=4

for c in {1..1}
do

loopSize=10
for i in {1..4}
do
    jobs=10000
    for k in {1..7}
    do
	echo "Threads: $threads    Jobs: $jobs    SleepTime: $sleepTime    MemSize: $memSize    LoopSize: $loopSize"
	(/usr/bin/time -f "%e" ../../bin/APIThread $threads $jobs $sleepTime $memSize $loopSize) 2>> ../../logs/logAPIThreadTest$c.txt

        jobs=$(($jobs+$jobs))
    done
    loopSize=$(($loopSize*10))
done

done