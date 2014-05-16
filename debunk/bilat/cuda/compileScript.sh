#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology


TMP_DIR=$PWD
WIDTH=1024
HEIGHT=1024
NUM_TASKS=84
LOG_DIR="filtering.dat"
echo "Width : $WIDTH Height: $HEIGHT"
WIDTH=$(($WIDTH/NUM_TASKS))
total_problem_size=$(($WIDTH * $HEIGHT))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*12)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

cd $TMP_DIR
make
max=4
# loop over Problem size
printf "\n" > $LOG_DIR

for j in $(seq 1 $max) 
do
    threads=1
    printf "$total_problem_size_bytes\t" >> $LOG_DIR
		# Loop over threads
		for i in {1..11} 
		do
	          ./filtering $WIDTH $HEIGHT $threads >> $LOG_DIR
		   threads=$(($threads*2))
		done
    # print a new line
    printf "\n" >> $LOG_DIR
    WIDTH=$(($WIDTH*2))
    total_problem_size=$(($WIDTH * $HEIGHT))
    total_problem_size_bytes=$(($total_problem_size*12))
done

#mv $LOG_DIR $TEMP_LOG_DIR
cd $TMP_DIR
exit


#make
#./filtering 4 10  > filtering.dat
#gnuplot format_bilat_time_670.p
#scp plots/bilat_time_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/bilat_time_670.png
make clean 
