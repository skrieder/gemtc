#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology
TMP_DIR=$PWD
image_width=100
mask_width=50
FLAG=1
LOG_DIR=/lus/scratch/p01956
echo "Image width in 1-D: $image_width"
echo "Mask width: $mask_width"
total_problem_size=$(($image_width+$mask_width))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*4)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

printf "#image_width\ttotal_problem_size\t#threads\ttime...\n"> $LOG_DIR/imageconv_raven.dat

cd $TMP_DIR
max=7 #For K20X
# loop over Problem size
for j in $(seq 1 $max) #20 is max on 460
do
    threads=1
     printf "$total_problem_size_bytes\t" >> $LOG_DIR/imageconv_raven.dat
    # Loop over threads
    for i in {1..11} # 11 = 1024
    do
	./imageconv $image_width $mask_width $threads $FLAG >> $LOG_DIR/imageconv_raven.dat 
	threads=$(($threads*2))
    done
    # print a new line
    printf "\n" >> $LOG_DIR/imageconv_raven.dat
    image_width=$(($image_width*10))
    total_problem_size=$(($image_width+$mask_width))
    total_problem_size_bytes=$(($total_problem_size*4))
done
  mv /lus/scratch/p01956/imageconv_raven.dat logs/imageconv_raven.dat
  gnuplot format_imageconv_mflops_raven.p
  scp plots/imageconv_mflops_data_incl_raven.png karthik@datasys.cs.iit.edu:~/public_html/
cd $TMP_DIR
exit
