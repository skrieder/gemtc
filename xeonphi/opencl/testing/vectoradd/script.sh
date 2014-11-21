#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./mvect 2 2 512 1
/usr/bin/time -f "%e" ./mvect 2 2 512 2
/usr/bin/time -f "%e" ./mvect 2 2 512 4
/usr/bin/time -f "%e" ./mvect 2 2 512 8
/usr/bin/time -f "%e" ./mvect 2 2 512 16
/usr/bin/time -f "%e" ./mvect 2 2 512 32
/usr/bin/time -f "%e" ./mvect 2 2 512 64
/usr/bin/time -f "%e" ./mvect 2 2 512 128
/usr/bin/time -f "%e" ./mvect 2 2 512 256
/usr/bin/time -f "%e" ./mvect 2 2 512 512
/usr/bin/time -f "%e" ./mvect 2 2 512 1024
/usr/bin/time -f "%e" ./mvect 2 2 512 2048
/usr/bin/time -f "%e" ./mvect 2 2 512 3072
/usr/bin/time -f "%e" ./mvect 2 2 512 4096
