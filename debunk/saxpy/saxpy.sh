#!/bin/bash 
#PBS -j oe 
#PBS -N SAXPY
#PBS -q gpu_nodes

echo "Running on: " 
cat ${PBS_NODEFILE} 

echo 
echo "Program Output begins: " 
cd ${PBS_O_WORKDIR} 

problem_size=100
num_threads=1
./cuda_saxpy 100 1

