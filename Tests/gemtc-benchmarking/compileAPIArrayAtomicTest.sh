#1
nvcc -arch=sm_11  APIArrayAtomicTest.cu -o ../../bin/APIArrayAtomicTest

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
