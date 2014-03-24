#!/bin/bash
echo "Compiling CUDA"
nvcc saxpy.cu -g -o saxpy
exit 0
