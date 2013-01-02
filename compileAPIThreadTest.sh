#1
nvcc -arch=sm_11  APIThreadTest.cu -o bin/APIThread

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
