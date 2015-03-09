#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./mvect 2 1 32 1000
/usr/bin/time -f "%e" ./mvect 2 1 32 1200
/usr/bin/time -f "%e" ./mvect 2 1 32 1400
/usr/bin/time -f "%e" ./mvect 2 1 32 1600
/usr/bin/time -f "%e" ./mvect 2 1 32 1800
/usr/bin/time -f "%e" ./mvect 2 1 32 2000
