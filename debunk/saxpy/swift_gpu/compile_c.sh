#! /bin/bash
echo "Compiling C"
echo "gcc saxpy.c -I /usr/local/cuda/include/ -L . -lsaxpy"
gcc saxpy.c -I /usr/local/cuda/include/ -L . -lsaxpy
