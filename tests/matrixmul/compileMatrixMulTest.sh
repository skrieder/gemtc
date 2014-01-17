mkdir -p  bin
#1
nvcc -arch=sm_20  MatrixMulTest.cu -o bin/MatrixMul

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
