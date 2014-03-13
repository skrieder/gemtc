#!/bin/bash 

# Karthik Balasubramanian
# Illinois Institute of Technology
# kbalasu3@hawkiit.edu

# usage: from gemtc/debunk/imageconv
# qsub sites/raven/submit.sh

#PBS -j oe 
#PBS -N GeMTC
#PBS -q gpu_nodes

echo "Running on: " 
cat ${PBS_NODEFILE} 

echo 
echo "Program Output begins: " 
cd ${PBS_O_WORKDIR} 

#aprun ./imageconv_r.sh
aprun ./imageconv 1 1 100 50 
#aprun ./MatrixMul 1 1 9 1
