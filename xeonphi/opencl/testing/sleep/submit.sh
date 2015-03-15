#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./sleep0 2 1 1 0
/usr/bin/time -f "%e" ./sleep0 2 1 1 1000000000000000000000000
