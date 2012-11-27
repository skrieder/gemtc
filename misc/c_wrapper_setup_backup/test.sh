#!/bin/bash

# declare some variables
bound=$1
workers=1
setup=2
mpi=$(($workers + $setup))

echo "Cleaing logs"
rm log.txt

echo "Setting Env Variables"
export TURBINE_CACHE_SIZE=0
export TURBINE_LOG=0

echo "Building TCL File"
#stc sleep.swift sleep.tcl
for j in {1..7}
do
    #echo "Running iteration " $j
    #while $count 
    #for i in {1..$(($loopcount))}
    for i in {1..1}
    do
	/usr/bin/time -f "%e" ./test-sleep1.sh $mpi $bound 2>> log.txt
    done
    workers=$(($workers + $workers))
    mpi=$(($workers + $setup))
done

echo "Printing logs"
cat log.txt