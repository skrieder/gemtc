#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
/usr/bin/time -f "%e" ./kmat 2 1 32 20
/usr/bin/time -f "%e" ./kmat 2 1 32 22
/usr/bin/time -f "%e" ./kmat 2 1 32 24
/usr/bin/time -f "%e" ./kmat 2 1 32 26
/usr/bin/time -f "%e" ./kmat 2 1 32 28
/usr/bin/time -f "%e" ./kmat 2 1 32 30
/usr/bin/time -f "%e" ./kmat 2 1 32 32
#/usr/bin/time -f "%e" ./mkvect 2 512 6000000
