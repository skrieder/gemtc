#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./vect 2 1024 1000000 >> vectvwl.txt
./vect 2 1024 10000000 >> vectvwl.txt
./vect 2 1024 100000000 >> vectvwl.txt
./vect 2 1024 1000000000 >> vectvwl.txt
./vect 2 1024 10000000000 >> vectvwl.txt
./vect 2 1024 100000000000 >> vectvwl.txt
