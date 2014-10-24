#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./kmat 2 1 64 10000000
/usr/bin/time -f "%e" ./kmat 2 1 128 10000000
/usr/bin/time -f "%e" ./kmat 2 1 256 10000000
/usr/bin/time -f "%e" ./kmat 2 1 384 10000000
/usr/bin/time -f "%e" ./kmat 2 1 512 10000000
/usr/bin/time -f "%e" ./kmat 2 1 1024 10000000
/usr/bin/time -f "%e" ./kmat 2 1 1536 10000000
#/usr/bin/time -f "%e" ./matm 1 512 100
#/usr/bin/time -f "%e" ./matm 2 512 100
