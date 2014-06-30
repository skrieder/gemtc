#!/bin/sh
rm ../../bin/APIThread
/usr/local/cuda-6.0/bin/nvcc -arch=sm_20  APIThreadTest.cu -o ../../bin/APIThread
exit
