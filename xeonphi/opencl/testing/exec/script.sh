#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./matm 2 1024 100000 >> matgct.txt &
./vect 2 1024 100000 >> vectgct.txt &
./matm 2 1024 1000000 >> matgct.txt &
./vect 2 1024 1000000 >> vectgct.txt &
./matm 2 1024 10000000 >> matgct.txt &
./vect 2 1024 10000000 >> vectgct.txt &
./matm 2 1024 100000000 >> matgct.txt &
./vect 2 1024 100000000 >> vectgct.txt &
./matm 2 1024 1000000000 >> matgct.txt &
./vect 2 1024 1000000000 >> vectgct.txt
./matm 1 512 10000 >> matcct.txt &
./vect 1 512 10000 >> vectcct.txt &
./matm 1 512 1000000 >> matcct.txt &
./vect 1 512 1000000 >> vectcct.txt &
./matm 1 512 10000000 >> matcct.txt &
./vect 1 512 10000000 >> vectcct.txt &
./matm 1 512 1000000000 >> matcct.txt &
./vect 1 512 1000000000 >> vectcct.txt 

