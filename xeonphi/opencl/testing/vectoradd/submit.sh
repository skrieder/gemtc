#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./vect 1 1024 100000 >> vectcg.txt
./vect 2 1024 100000000 >> vectcg.txt
./vect 2 1024 1000000 >> vectcg.txt
./vect 2 1024 100000000 >> vectcg.txt
./vect 2 1024 100000000 >> vectcg.txt
./vect 2 1024 100000000 >> vectcg.txt
