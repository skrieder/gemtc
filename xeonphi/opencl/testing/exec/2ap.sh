#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./vect 2 1024 100000000 >> 2ag.txt &
./matm 2 1024 1000000000 >> 2ag.txt
./matm 1 512 1000000000 >> 2ac.txt &
./vect 1 512 1000000000 >> 2ac.txt
./matm 2 1024 100000 >> 4ag.txt &
./vect 2 1024 100000 >> 4ag.txt &
./matm 2 1024 1000000 >> 4ag.txt &
./vect 2 1024 1000000 >> 4ag.txt
./matm 1 512 10000 >> 4ac.txt &
./vect 1 512 10000 >> 4ac.txt &
./matm 1 512 1000000 >> 4ac.txt &
./vect 1 512 1000000 >> 4ac.txt  

