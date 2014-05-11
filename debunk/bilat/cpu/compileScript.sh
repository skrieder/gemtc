#!/bin/bash

# Karthik Balasubramanian
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology


TMP_DIR=$PWD
WIDTH=$1
HEIGHT=1024
NUM_TASKS=84
LOG_DIR="flitering.dat"

WIDTH=$(($WIDTH/$NUM_TASKS))
total_problem_size=$(($WIDTH*$HEIGHT))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*12)) # 4 because 4 bytes in a float
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
		     			
                  ./filtering $WIDTH $HEIGHT >> $LOG_DIR
                  done
 
                done
    # print a new line
    printf "\n" >> $LOG_DIR
    WIDTH=$(($WIDTH*2))
    total_problem_size=$(($WIDTH * $HEIGHT/$NUM_TASKS))
    total_problem_size_bytes=$(($total_problem_size*12))
done

cd $TMP_DIR

make clean 
exit
#make
#./filtering 4 1 > filtering.dat
#gnuplot format_bilat_time_cpu.p
#scp plots/bilat_time_cpu.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/bilat_time_cpu.png
#make clean 

