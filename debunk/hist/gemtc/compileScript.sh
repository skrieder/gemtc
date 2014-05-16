#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology


TMP_DIR=$PWD
HISTO_SIZE=25600
LOG_DIR="histogram.dat"
TEMP_LOG_DIR="histogram_bkp.dat"
echo "Histogram size: $HISTO_SIZE"

total_problem_size=$(($HISTO_SIZE ))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*4)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

cd $TMP_DIR
make
max=5
# loop over Problem size
for j in $(seq 1 $max) 
do
    threads=1
    printf "$total_problem_size_bytes\t" >> $LOG_DIR
		# Loop over threads
		for i in {1..9} 
		do
	          ./histogram $HISTO_SIZE $threads >> $LOG_DIR
		   threads=$(($threads*2))
		done
    # print a new line
    printf "\n" >> $LOG_DIR
    HISTO_SIZE=$(($HISTO_SIZE*10))
    total_problem_size=$(($HISTO_SIZE))
    total_problem_size_bytes=$(($total_problem_size*4))
done

mv $LOG_DIR $TEMP_LOG_DIR
cd $TMP_DIR
exit




#make
#./histogram 5 10 > histogram.dat
#gnuplot format_histogram_time_670.p
#gnuplot format_histogram_thrgh_670.p
#scp plots/hist_throughput_GemTC_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_GemTC_670.png
#scp plots/hist_time_GemTC_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_GemTC_670.png


make clean 
