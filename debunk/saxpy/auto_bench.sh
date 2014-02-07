#!/bin/bash

# Scott J. Krieder
# skrieder@iit.edu
# Illinois Institute of Technology

problem_size=100
echo "Vector Size (array elements): $problem_size"
total_problem_size=$(($problem_size*2))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*4)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

printf "#problem_size\ttime...\n"> logs/saxpy_log.dat

# loop over Problem size
for j in {1..20} #22 is max on 670
do
    threads=1
    # Loop over threads
    printf "$total_problem_size_bytes\t" >> logs/saxpy_log.dat
    for i in {1..11} # 11 = 1024
    do
	./cuda_saxpy $problem_size $threads >> logs/saxpy_log.dat 
	threads=$(($threads*2))
    done
    # print a new line
    printf "\n" >> logs/saxpy_log.dat
    problem_size=$(($problem_size*2))
    total_problem_size=$(($problem_size*2))
    total_problem_size_bytes=$(($total_problem_size*4))
done
TMP_DIR=$PWD

gnuplot format_saxpy_mflops.p
scp plots/saxpy_mflops_data_incl.png skrieder@datasys.cs.iit.edu:~/public_html/scratch/saxpy

cd $TMP_DIR
exit
