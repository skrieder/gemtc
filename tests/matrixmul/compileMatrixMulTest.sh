mkdir -p  bin
nvcc -arch=sm_20  MatrixMulTest.cu -o bin/MatrixMul
exit