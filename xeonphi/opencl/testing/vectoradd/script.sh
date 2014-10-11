#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./mvect 2 512 10000
/usr/bin/time -f "%e" ./mvect 2 512 100000
/usr/bin/time -f "%e" ./mvect 2 512 1000000
/usr/bin/time -f "%e" ./vect 2 512 10000000
/usr/bin/time -f "%e" ./vect 2 512 100000000
/usr/bin/time -f "%e" ./vect 2 512 1000000000
