#1
nvcc -arch=sm_11  APIVecAddTest.cu -o ../../bin/APIVecAdd

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
