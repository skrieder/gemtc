#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 1 64 1000000000
/usr/bin/time -f "%e" ./vect 1 128 1000000000
/usr/bin/time -f "%e" ./vect 1 256 1000000000
/usr/bin/time -f "%e" ./vect 1 384 1000000000
/usr/bin/time -f "%e" ./vect 1 512 1000000000
/usr/bin/time -f "%e" ./vect 1 768 1000000000
/usr/bin/time -f "%e" ./vect 1 1024 1000000000
