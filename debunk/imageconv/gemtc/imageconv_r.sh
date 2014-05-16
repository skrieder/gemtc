#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology
TMP_DIR=$PWD
image_width=100
mask_width=50
FLAG=1
LOOP_SIZE=1
NUM_TASK=1
LOG_DIR=/lus/scratch/p01956
echo "Image width in 1-D: $image_width"
echo "Mask width: $mask_width"
total_problem_size=$(($image_width+$mask_width))
echo "Total Problem Size (array elements): $total_problem_size"
total_problem_size_bytes=$(($total_problem_size*4)) # 4 because 4 bytes in a float
echo "Total Problem Size (bytes): $total_problem_size_bytes"

printf "#image_width\ttotal_problem_size\t#threads\ttime...\n"> $LOG_DIR/imageconv_G.dat

max=7
# loop over Problem size
for j in $(seq 1 $max) #20 is max on 460
do
    threads=1
     printf "$total_problem_size_bytes\t" >> $LOG_DIR/imageconv_G.dat
    # Loop over threads
    #for i in {1..11} # 11 = 1024
    #do
	./imageconv $NUM_TASK $LOOP_SIZE $image_width $mask_width >> $LOG_DIR/imageconv_G.dat 
	#threads=$(($threads*2))
    #done
    # print a new line
    printf "\n" >> $LOG_DIR/imageconv_G.dat
    image_width=$(($image_width*10))
    total_problem_size=$(($image_width+$mask_width))
    total_problem_size_bytes=$(($total_problem_size*4))
done

 gnuplot format_imageconv_mflops_raven.p
 scp plots/imageconv_mflops_data_incl_raven_gemtc.png karthik@datasys.cs.iit.edu:~/public_html/imageconv_mflops_data_incl_raven_gemtc.png

 cp $LOG_DIR/imageconv_G.dat imageconv_G.dat
#if [$FLAG -eq 1]
#then
 # gnuplot format_imageconv_mflops.p
  #scp plots/imageconv_mflops_data_incl_460.png karthik@datasys.cs.iit.edu:~/public_html/
#else
 # gnuplot format_imageconv_mflops_do.p
  #scp plots/imageconv_mflops_data_incl_460_onlygpu.png karthik@datasys.cs.iit.edu:~/public_html/
#fi
cd $TMP_DIR
exit
