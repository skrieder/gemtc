#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./matm 16 >> matrix.txt
./matm 32 >> matrix.txt
./matm 64 >> matrix.txt
./matm 128 >> matrix.txt
./matm 256 >> matrix.txt
./matm 384 >> matrix.txt
./matm 512 >> matrix.txt
