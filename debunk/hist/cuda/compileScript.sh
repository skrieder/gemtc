#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology


TMP_DIR=$PWD
HISTO_SIZE=25600
NUM_TASKS=84
NUM_TEST=100000
LOG_DIR="histogram.dat"
echo "Histogram size: $HISTO_SIZE"

total_problem_size=$(($HISTO_SIZE/$NUM_TASKS))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*4)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

cd $TMP_DIR
make
max=5
# loop over Problem size
printf "\n" > $LOG_DIR
for j in $(seq 1 $max) 
do
    threads=1
    printf "$total_problem_size_bytes\t" >> $LOG_DIR
		# Loop over threads
		for i in {1..9} 
		do
	          ./histogram $HISTO_SIZE $threads $NUM_TASKS $NUM_TEST>> $LOG_DIR
		   threads=$(($threads*2))
		done
    # print a new line
    printf "\n" >> $LOG_DIR
    HISTO_SIZE=$(($HISTO_SIZE*10))
    NUM_TEST=$(($NUM_TEST/10))
    total_problem_size=$(($HISTO_SIZE/$NUM_TASKS))
    total_problem_size_bytes=$(($total_problem_size*4))
done

cd $TMP_DIR
exit


#make
#./histogram 5 10 > histogram.dat
#gnuplot format_histogram_time_670.p
#gnuplot format_histogram_thrgh_670.p
#scp plots/hist_throughput_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_670.png
#scp plots/hist_time_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_670.png
make clean 
