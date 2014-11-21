#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./matm 6 64
/usr/bin/time -f "%e" ./matm 6 128
/usr/bin/time -f "%e" ./matm 6 256
/usr/bin/time -f "%e" ./matm 6 512
/usr/bin/time -f "%e" ./matm 6 1024
/usr/bin/time -f "%e" ./matm 6 2048
/usr/bin/time -f "%e" ./matm 6 3072
/usr/bin/time -f "%e" ./matm 6 4096
