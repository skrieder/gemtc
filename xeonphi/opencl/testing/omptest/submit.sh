#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 6 100000000
/usr/bin/time -f "%e" ./vect 6 200000000
/usr/bin/time -f "%e" ./vect 6 300000000
/usr/bin/time -f "%e" ./vect 6 400000000
/usr/bin/time -f "%e" ./vect 6 500000000
/usr/bin/time -f "%e" ./vect 6 600000000
/usr/bin/time -f "%e" ./vect 6 700000000
