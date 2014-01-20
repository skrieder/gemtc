mkdir -p  bin
#1
nvcc -arch=sm_20  MatrixDetTest.cu -o bin/MatrixDet

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
