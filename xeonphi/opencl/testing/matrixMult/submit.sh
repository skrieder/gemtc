#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./matm 2 1024 1000 >> matvarwl.txt
./matm 2 1024 10000 >> matvarwl.txt
./matm 2 1024 1000000 >> matvarwl.txt
./matm 2 1024 10000000 >> matvarwl.txt
./matm 2 1024 1000000000 >> matvarwl.txt
