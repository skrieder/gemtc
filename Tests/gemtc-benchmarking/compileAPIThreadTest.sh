#!/bin/sh
/usr/local/cuda-5.0/bin/nvcc -arch=sm_11  APIThreadTest123.cu -o ../../bin/APIThread
exit
