#!/bin/bash 

# Scott J. Krieder
# Illinois Institute of Technology
# skrieder@iit.edu

# usage: from gemtc/debunk/saxpy
# qsub sites/raven/submit.sh

#PBS -j oe 
#PBS -N GeMTC
#PBS -q gpu_nodes

echo "Running on: " 
cat ${PBS_NODEFILE} 

echo 
echo "Program Output begins: " 
cd ${PBS_O_WORKDIR} 

aprun ./auto_bench.sh
