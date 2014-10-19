#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./mvect 2 128 512 1
/usr/bin/time -f "%e" ./mvect 2 128 512 2
/usr/bin/time -f "%e" ./mvect 2 128 512 4
/usr/bin/time -f "%e" ./mvect 2 128 512 8
/usr/bin/time -f "%e" ./mvect 2 128 512 16
/usr/bin/time -f "%e" ./mvect 2 128 512 32
/usr/bin/time -f "%e" ./mvect 2 128 512 64
/usr/bin/time -f "%e" ./mvect 2 128 512 128
/usr/bin/time -f "%e" ./mvect 2 128 512 256
/usr/bin/time -f "%e" ./mvect 2 128 512 512
/usr/bin/time -f "%e" ./mvect 2 128 512 1024
/usr/bin/time -f "%e" ./mvect 2 128 512 2048
/usr/bin/time -f "%e" ./mvect 2 128 512 3072
/usr/bin/time -f "%e" ./mvect 2 128 512 4096
#/usr/bin/time -f "%e" ./mvect 2 4 512 6000000
#/usr/bin/time -f "%e" ./mkvect 2 512 6000000
