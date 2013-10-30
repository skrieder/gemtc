#1
nvcc -arch=sm_11  APIArrayRotateTest.cu -o ../../bin/APIArrayRotateTest

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
