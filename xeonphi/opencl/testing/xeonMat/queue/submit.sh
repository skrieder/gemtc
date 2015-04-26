#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
/usr/bin/time -f "%e" ./kqmat 2 1 1 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 1 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 2 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 4 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 8 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 16 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 32 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 64 32 1 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 84 32 1 >> out.txt
echo "end of task 1"
/usr/bin/time -f "%e" ./kqmat 2 1 1 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 1 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 2 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 4 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 8 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 16 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 32 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 64 32 2 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 84 32 2 >> out.txt
echo "end of task 2"
/usr/bin/time -f "%e" ./kqmat 2 1 1 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 1 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 2 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 4 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 8 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 16 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 32 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 64 32 4 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 84 32 4 >> out.txt
echo "end of task 3"
/usr/bin/time -f "%e" ./kqmat 2 1 1 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 1 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 2 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 4 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 8 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 16 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 32 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 64 32 8 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 84 32 8 >> out.txt
echo "end of task 4"
/usr/bin/time -f "%e" ./kqmat 2 1 1 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 1 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 2 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 4 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 8 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 16 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 32 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 64 32 16 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 84 32 16 >> out.txt
echo "end of task 5"
/usr/bin/time -f "%e" ./kqmat 2 1 1 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 1 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 2 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 4 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 8 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 16 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 32 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 64 32 32 >> out.txt
/usr/bin/time -f "%e" ./kqmat 2 100 84 32 32 >> out.txt
echo "end of task 6"
