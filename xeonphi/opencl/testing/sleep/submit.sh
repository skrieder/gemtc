#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./sleep0 2 1 1000 0
/usr/bin/time -f "%e" ./sleep0 2 1 1000 100000000000000000000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 10
/usr/bin/time -f "%e" ./sleep0 2 1 1000 100
/usr/bin/time -f "%e" ./sleep0 2 1 1000 1000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 10000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 100000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 1000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 10000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 100000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 1000000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 10000000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 100000000000
/usr/bin/time -f "%e" ./sleep0 2 1 1000 1000000000000
/usr/bin/time -f "%e" ./sleep0 2 1 1 10000000000000
