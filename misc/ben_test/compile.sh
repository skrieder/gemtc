#!/bin/bash
echo "Compiling CUDA"
nvcc vadd.cu -o vadd
exit 0
