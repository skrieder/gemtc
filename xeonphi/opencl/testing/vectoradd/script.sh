#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 1 512 10000000
/usr/bin/time -f "%e" ./vect 1 512 20000000
/usr/bin/time -f "%e" ./vect 1 512 30000000
/usr/bin/time -f "%e" ./vect 1 512 40000000
/usr/bin/time -f "%e" ./vect 1 512 50000000
/usr/bin/time -f "%e" ./vect 1 512 60000000
/usr/bin/time -f "%e" ./vect 1 512 70000000
