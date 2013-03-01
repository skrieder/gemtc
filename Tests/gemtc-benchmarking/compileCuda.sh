#1
nvcc -arch=sm_11 -c -Xcompiler -fPIC ../../gemtc.cu
#2
nvcc -arch=sm_11 --shared -o ../../libtest.so gemtc.o 

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
