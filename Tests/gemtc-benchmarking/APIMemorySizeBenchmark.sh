#! /bin/bash

sleepTime=0
threads=1
loopSize=100;

for c in {1..2}
do

memSize=524288
for i in {1..3}
do
    jobs=10000
    for k in {1..8}
    do
	echo "Threads: $threads    Jobs: $jobs    SleepTime: $sleepTime    MemSize: $memSize    LoopSize: $loopSize"
	(/usr/bin/time -f "%e" ../../bin/APIThread $threads $jobs $sleepTime $memSize $loopSize) 2>> ../../logs/logAPIThreadTest$c.txt

        jobs=$(($jobs+$jobs))
    done
    memSize=$(($memSize*2))
done

done