#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./vect 32 1 >> vectcg.txt
./vect 64 1 >> vectcg.txt
./vect 128 1 >> vectcg.txt
./vect 256 1 >> vectcg.txt
./vect 384 1 >> vectcg.txt
./vect 512 1 >> vectcg.txt
./vect 32 2 >> vectcg.txt
./vect 64 2 >> vectcg.txt
./vect 128 2 >> vectcg.txt
./vect 256 2 >> vectcg.txt
./vect 384 2 >> vectcg.txt
./vect 512 2 >> vectcg.txt
