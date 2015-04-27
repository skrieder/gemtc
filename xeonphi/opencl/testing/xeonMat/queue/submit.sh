#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
./kqmat 1 1 1 512 100 >> out.txt
./kqmat 1 300 10 512 100 >> out.txt
./kqmat 1 300 40 512 100 >> out.txt
./kqmat 1 300 80 512 100 >> out.txt
./kqmat 1 300 120 512 100 >> out.txt
./kqmat 1 300 160 512 100 >> out.txt
./kqmat 1 300 200 512 100 >> out.txt
./kqmat 1 300 240 512 100 >> out.txt
echo "end of task 1" >> out.txt
./kqmat 1 1 1 512 1000 >> out.txt
./kqmat 1 300 10 512 1000 >> out.txt
./kqmat 1 300 40 512 1000 >> out.txt
./kqmat 1 300 80 512 1000 >> out.txt
./kqmat 1 300 120 512 1000 >> out.txt
./kqmat 1 300 160 512 1000 >> out.txt
./kqmat 1 300 200 512 1000 >> out.txt
./kqmat 1 300 240 512 1000 >> out.txt
echo "end of task 2" >> out.txt
./kqmat 1 1 1 512 10000 >> out.txt
./kqmat 1 300 10 512 10000 >> out.txt
./kqmat 1 300 40 512 10000 >> out.txt
./kqmat 1 300 80 512 10000 >> out.txt
./kqmat 1 300 120 512 10000 >> out.txt
./kqmat 1 300 160 512 10000 >> out.txt
./kqmat 1 300 200 512 10000 >> out.txt
./kqmat 1 300 240 512 10000 >> out.txt
echo "end of task 3" >> out.txt
./kqmat 1 1 1 512 100000 >> out.txt
./kqmat 1 300 10 512 100000 >> out.txt
./kqmat 1 300 40 512 100000 >> out.txt
./kqmat 1 300 80 512 100000 >> out.txt
./kqmat 1 300 120 512 100000 >> out.txt
./kqmat 1 300 160 512 100000 >> out.txt
./kqmat 1 300 200 512 100000 >> out.txt
./kqmat 1 300 240 512 100000 >> out.txt
echo "end of task 4" >> out.txt
./kqmat 1 1 1 512 1000000 >> out.txt
./kqmat 1 300 10 512 1000000 >> out.txt
./kqmat 1 300 40 512 1000000 >> out.txt
./kqmat 1 300 80 512 1000000 >> out.txt
./kqmat 1 300 120 512 1000000 >> out.txt
./kqmat 1 300 160 512 1000000 >> out.txt
./kqmat 1 300 200 512 1000000 >> out.txt
./kqmat 1 300 240 512 1000000 >> out.txt
echo "end of task 5" >> out.txt
./kqmat 1 1 1 512 10000000 >> out.txt
./kqmat 1 300 10 512 10000000 >> out.txt
./kqmat 1 300 40 512 10000000 >> out.txt
./kqmat 1 300 80 512 10000000 >> out.txt
./kqmat 1 300 120 512 10000000 >> out.txt
./kqmat 1 300 160 512 10000000 >> out.txt
./kqmat 1 300 200 512 10000000 >> out.txt
./kqmat 1 300 240 512 10000000 >> out.txt
echo "end of task 6" >> out.txt
