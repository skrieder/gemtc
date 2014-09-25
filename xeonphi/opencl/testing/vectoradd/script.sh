#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./vect 1 4 500000000
/usr/bin/time -f "%e" ./vect 1 8 500000000
/usr/bin/time -f "%e" ./vect 1 16 500000000
/usr/bin/time -f "%e" ./vect 1 32 500000000
/usr/bin/time -f "%e" ./vect 1 64 500000000
/usr/bin/time -f "%e" ./vect 1 128 500000000
/usr/bin/time -f "%e" ./vect 1 256 500000000
/usr/bin/time -f "%e" ./vect 1 384 500000000
/usr/bin/time -f "%e" ./vect 1 512 500000000
/usr/bin/time -f "%e" ./vect 1 768 500000000
/usr/bin/time -f "%e" ./vect 1 1024 500000000
/usr/bin/time -f "%e" ./vect 1 1536 500000000
/usr/bin/time -f "%e" ./vect 1 2048 500000000
/usr/bin/time -f "%e" ./vect 1 3072 500000000
