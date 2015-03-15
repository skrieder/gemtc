#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
/usr/bin/time -f "%e" ./kqmat 2 1 32 1
#/usr/bin/time -f "%e" ./mkvect 2 512 6000000
