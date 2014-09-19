#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./matm 2 1024 10 >> matrix.txt
./matm 2 1024 100 >> matrix.txt
./matm 2 1024 1000 >> matrix.txt
./matm 2 512 10000 >> matrix.txt
./matm 2 512 1000000 >> matrix.txt
./matm 2 512 10000000 >> matrix.txt
