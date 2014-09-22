#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./vect 2 1024 100000 >> vectgvwl.txt
./vect 2 1024 1000000 >> vectgvwl.txt
./vect 2 1024 10000000 >> vectgvwl.txt
./vect 2 1024 1000000000 >> vectgvwl.txt
./vect 2 1024 10000000000 >> vectgvwl.txt
./vect 1 512 100000 >> vectcvwl.txt
./vect 1 512 1000000 >> vectcvwl.txt
./vect 1 512 10000000 >> vectcvwl.txt
./vect 1 512 100000000 >> vectcvwl.txt
./vect 1 512 1000000000 >> vectcvwl.txt
./matm 2 1024 1000 >> matgvwl.txt
./matm 2 1024 10000 >> matgvwl.txt
./matm 2 1024 1000000 >> matgvwl.txt
./matm 2 1024 10000000 >> matgvwl.txt
./matm 2 1024 1000000000 >> matgvwl.txt
./matm 1 512 1000 >> matcvwl.txt
./matm 1 512 10000 >> matcvwl.txt
./matm 1 512 1000000 >> matcvwl.txt
./matm 1 512 10000000 >> matcvwl.txt
./matm 1 512 1000000000 >> matcvwl.txt
