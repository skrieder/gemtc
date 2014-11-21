#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./kmat 2 1 512 1
/usr/bin/time -f "%e" ./kmat 2 1 512 2
/usr/bin/time -f "%e" ./kmat 2 1 512 4
/usr/bin/time -f "%e" ./kmat 2 1 512 8
/usr/bin/time -f "%e" ./kmat 2 1 512 16
/usr/bin/time -f "%e" ./kmat 2 1 512 32
/usr/bin/time -f "%e" ./kmat 2 1 512 64
/usr/bin/time -f "%e" ./kmat 2 1 512 128
#/usr/bin/time -f "%e" ./matm 1 512 100
#/usr/bin/time -f "%e" ./matm 2 512 100
