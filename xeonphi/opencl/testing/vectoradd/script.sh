#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 1 512 100000000
/usr/bin/time -f "%e" ./vect 1 512 200000000
/usr/bin/time -f "%e" ./vect 1 512 300000000
/usr/bin/time -f "%e" ./vect 1 512 400000000
/usr/bin/time -f "%e" ./vect 1 512 500000000
/usr/bin/time -f "%e" ./vect 1 512 600000000
/usr/bin/time -f "%e" ./vect 1 512 700000000
