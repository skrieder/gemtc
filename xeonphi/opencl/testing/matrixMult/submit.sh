#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
#/usr/bin/time -f "%e" ./kmat 1 1 512 128
#/usr/bin/time -f "%e" ./kmat 1 1 512 256
#/usr/bin/time -f "%e" ./kmat 1 1 512 512
#/usr/bin/time -f "%e" ./kmat 1 1 512 1024
#/usr/bin/time -f "%e" ./kmat 1 1 512 2048
#/usr/bin/time -f "%e" ./kmat 1 1 512 3072
#/usr/bin/time -f "%e" ./kmat 1 1 512 4096
/usr/bin/time -f "%e" ./matm 1 512 100
