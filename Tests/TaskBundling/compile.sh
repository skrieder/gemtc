#1
nvcc -arch=sm_11  BundlingTest.cu -o ../../bin/BundlingTest

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
