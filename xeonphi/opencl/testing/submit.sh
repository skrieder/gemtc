#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./bigcuda2 60 256 >> gpu.txt
./bigcuda2 30 512 >> gpu2.txt
./bigcuda2 60 128 >> gpu3.txt
./bigcuda2 60 64 >> gpu4.txt
./bigcuda2 60 384 >> gpu5.txt
