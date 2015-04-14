#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./mvect 2 1 32 100
/usr/bin/time -f "%e" ./mvect 2 1 32 1000
/usr/bin/time -f "%e" ./mvect 2 1 32 10000
/usr/bin/time -f "%e" ./mvect 2 1 32 100000
/usr/bin/time -f "%e" ./mvect 2 1 32 800000
/usr/bin/time -f "%e" ./mvect 2 1 32 900000
echo "end of task 1"
/usr/bin/time -f "%e" ./mvect 2 1 16 100
/usr/bin/time -f "%e" ./mvect 2 1 16 1000
/usr/bin/time -f "%e" ./mvect 2 1 16 10000
/usr/bin/time -f "%e" ./mvect 2 1 16 100000
/usr/bin/time -f "%e" ./mvect 2 1 16 800000
/usr/bin/time -f "%e" ./mvect 2 1 16 900000
echo "end of task 2"
/usr/bin/time -f "%e" ./mvect 2 1 8 100
/usr/bin/time -f "%e" ./mvect 2 1 8 1000
/usr/bin/time -f "%e" ./mvect 2 1 8 10000
/usr/bin/time -f "%e" ./mvect 2 1 8 100000
/usr/bin/time -f "%e" ./mvect 2 1 8 1000000
/usr/bin/time -f "%e" ./mvect 2 1 8 2000000
echo "end of task 3"
/usr/bin/time -f "%e" ./mvect 2 1 4 100
/usr/bin/time -f "%e" ./mvect 2 1 4 1000
/usr/bin/time -f "%e" ./mvect 2 1 4 10000
/usr/bin/time -f "%e" ./mvect 2 1 4 100000
/usr/bin/time -f "%e" ./mvect 2 1 4 1000000
/usr/bin/time -f "%e" ./mvect 2 1 4 2000000
echo "end of task 4"
/usr/bin/time -f "%e" ./mvect 2 1 2 100
/usr/bin/time -f "%e" ./mvect 2 1 2 1000
/usr/bin/time -f "%e" ./mvect 2 1 2 10000
/usr/bin/time -f "%e" ./mvect 2 1 2 100000
/usr/bin/time -f "%e" ./mvect 2 1 2 1000000
/usr/bin/time -f "%e" ./mvect 2 1 2 2000000
echo "end of task 5"
/usr/bin/time -f "%e" ./mvect 2 1 1 100
/usr/bin/time -f "%e" ./mvect 2 1 1 1000
/usr/bin/time -f "%e" ./mvect 2 1 1 10000
/usr/bin/time -f "%e" ./mvect 2 1 1 100000
/usr/bin/time -f "%e" ./mvect 2 1 1 1000000
/usr/bin/time -f "%e" ./mvect 2 1 1 2000000
echo "end of task 6"
