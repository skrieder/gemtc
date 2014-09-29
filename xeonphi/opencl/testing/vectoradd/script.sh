#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 2 512 1000000000 &
/usr/bin/time -f "%e" ./vect 2 512 1000000000 &
/usr/bin/time -f "%e" ./vect 2 512 1000000000 &
/usr/bin/time -f "%e" ./vect 2 512 1000000000 &
/usr/bin/time -f "%e" ./vect 2 512 1000000000 &
/usr/bin/time -f "%e" ./vect 2 512 1000000000
