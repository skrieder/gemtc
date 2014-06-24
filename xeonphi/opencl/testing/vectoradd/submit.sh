#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
./vect 8 512 >> vecto.txt
./vect 32 512 >> vecto.txt
./vect 64 512 >> vecto.txt
./vect 128 512 >> vecto.txt
./vect 256 512 >> vecto.txt
./vect 384 512 >> vecto.txt
./vect 448 512 >> vecto.txt
