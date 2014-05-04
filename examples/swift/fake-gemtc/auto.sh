#!/bin/bash
NODES=1
PPN=$((3*$NODES))
sleep_time=1000000
#bound=10080
gpu_workers=$(($NODES*168))
n=$(($PPN * $NODES))
launch_time=$(date +"%m-%d-%y_%H_%M_%S")
counter=1
seconds=$(($sleep_time/1000000))

# Write the header to the log
echo "Job#, NODES, PPN, Tasks, Sleep Time, GPU Workers, Output Dir" >> logs/autorunlog_$launch_time.txt

#i=1
for i in {1..5}
do
    # Reset Params
    seconds=$(($sleep_time/1000000))
    bound=$((60*$gpu_workers/$seconds))

    for j in {1..5}
    do
#for 1 to 16 minutes
	echo "LAUNCHING JOB:" $counter
	echo "  NODES:" $NODES
	echo "  PPN:" $PPN
	echo "  Tasks:" $bound
	echo "  Sleep Time(Microseconds):" $(($sleep_time))
	echo "  nprocs:" $n
	echo "  GPU Workers:" $gpu_workers
	
#RUN 
WALLTIME=00:29:00 FEATURE=xk TURBINE_ENGINES=$NODES ADLB_SERVERS=$NODES QUEUE=normal BLUE_WATERS=true PPN=$PPN turbine-aprun-run.zsh -n $n test_gemtc_parallel.tcl -bound=$bound -sleeptime=$sleep_time
	output_dir=$(cat turbine-directory.txt)

# Write to the log file
	echo $counter"," $NODES"," $PPN"," $bound"," $sleep_time"," $gpu_workers"," $output_dir >> logs/autorunlog_$launch_time.txt
	# Update params
	counter=$(($counter+1))
	bound=$(($bound*2))
    done
    
    sleep_time=$(($sleep_time*2))

done
