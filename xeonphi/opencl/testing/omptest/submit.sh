#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 6 10000000
/usr/bin/time -f "%e" ./vect 6 20000000
/usr/bin/time -f "%e" ./vect 6 30000000
/usr/bin/time -f "%e" ./vect 6 40000000
/usr/bin/time -f "%e" ./vect 6 50000000
/usr/bin/time -f "%e" ./vect 6 60000000
/usr/bin/time -f "%e" ./vect 6 70000000
