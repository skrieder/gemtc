#!/bin/bash

# Karthik Balasubramanian
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology


TMP_DIR=$PWD
HISTO_SIZE=$1
NUM_TASKS=84
LOG_DIR="histogram.dat"
echo "Histogram size: $HISTO_SIZE"

total_problem_size=$(($HISTO_SIZE/$NUM_TASKS))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*4)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

cd $TMP_DIR
make

max=1
# loop over Problem size
printf "\n" > $LOG_DIR
for j in $(seq 1 $max)
do
    printf "$total_problem_size_bytes\t" >> $LOG_DIR
                # Loop over threads
                for i in {1..14}
                do
		  for j in {1..6}
		  do
		     			
                  ./histogram $total_problem_size >> $LOG_DIR
                  done
 
                done
    # print a new line
    printf "\n" >> $LOG_DIR
    HISTO_SIZE=$(($HISTO_SIZE*10))
    total_problem_size=$(($HISTO_SIZE/$NUM_TASKS))
    total_problem_size_bytes=$(($total_problem_size*4))
done

cd $TMP_DIR

#make
#./histogram 5 > histogram.dat
#gnuplot format_histogram_time_cpu.p
#gnuplot format_histogram_thrgh_cpu.p
#scp plots/hist_throughput_cpu.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_cpu.png
#scp plots/hist_time_cpu.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_cpu.png
make clean 
exit
