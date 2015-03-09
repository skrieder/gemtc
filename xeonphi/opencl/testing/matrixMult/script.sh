#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
/usr/bin/time -f "%e" ./kmat 2 1 32 10
/usr/bin/time -f "%e" ./kmat 2 16 32 10
/usr/bin/time -f "%e" ./kmat 2 32 32 10
/usr/bin/time -f "%e" ./kmat 2 64 32 10
/usr/bin/time -f "%e" ./kmat 2 128 32 10
/usr/bin/time -f "%e" ./kmat 2 256 32 10
/usr/bin/time -f "%e" ./kmat 2 512 32 10
/usr/bin/time -f "%e" ./kmat 2 1024 32 10
/usr/bin/time -f "%e" ./kmat 2 2048 32 10
/usr/bin/time -f "%e" ./kmat 2 4096 32 10
/usr/bin/time -f "%e" ./kmat 2 8192 32 10
/usr/bin/time -f "%e" ./kmat 2 16384 32 10
/usr/bin/time -f "%e" ./kmat 2 32768 32 10
echo "task 5 end"
#/usr/bin/time -f "%e" ./mkvect 2 512 6000000
