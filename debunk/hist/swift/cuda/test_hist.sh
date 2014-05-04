#!/bin/sh

nvcc -arch=sm_20 -I ../../../../samples_include/inc/ -c hist.cu || exit 1
nvcc -c test_hist.c || exit 1
nvcc -o hist.x test_hist.o hist.o || exit 1

