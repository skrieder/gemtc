#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./serial 2 1 512 1
/usr/bin/time -f "%e" ./serial 2 1 512 2
/usr/bin/time -f "%e" ./serial 2 1 512 4
/usr/bin/time -f "%e" ./serial 2 1 512 8
/usr/bin/time -f "%e" ./serial 2 1 512 16
/usr/bin/time -f "%e" ./serial 2 1 512 32
/usr/bin/time -f "%e" ./serial 2 1 512 64
/usr/bin/time -f "%e" ./serial 2 1 512 128
/usr/bin/time -f "%e" ./serial 2 1 512 256
#/usr/bin/time -f "%e" ./mvect 133 512 6000000
#/usr/bin/time -f "%e" ./mkvect 2 512 6000000
