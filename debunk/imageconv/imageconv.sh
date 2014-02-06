#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology

image_width=100
mask_width=5
echo "Image width in 1-D: $image_width"
echo "Mask width: $mask_width"


printf "#image_width\ttime...\n"> logs/imageconv.dat

# loop over Problem size
for j in {1..22} #22 is max on 670
do
    threads=1
    # Loop over threads
    for i in {1..11} # 11 = 1024
    do
    	printf "$image_width\t$threads\t" >> logs/imageconv.dat
	./imageconv $image_width $mask_width $threads >> logs/imageconv.dat 
	threads=$(($threads*2))
    done
    # print a new line
    printf "\n" >> logs/imageconv.dat
    image_width=$(($image_width*2))
done
TMP_DIR=$PWD

#gnuplot format_saxpy_mflops.p
#scp plots/saxpy_mflops_data_incl.png skrieder@datasys.cs.iit.edu:~/public_html/scratch/saxpy

cd $TMP_DIR
exit
