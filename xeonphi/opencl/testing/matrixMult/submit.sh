#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./kmat 1 2 512 10000000
/usr/bin/time -f "%e" ./matm 1 512 10000000
/usr/bin/time -f "%e" ./matm 1 512 10000000
