mkdir bin
#1
nvcc -arch=sm_20  APIMatrixTest.cu -o bin/APIMatrix

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
