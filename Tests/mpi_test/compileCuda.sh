#1
nvcc -arch=sm_11 -c -Xcompiler -fPIC addSleep.cu
#2
nvcc -arch=sm_11 --shared -o libtest.so addSleep.o 

#nvcc -arch=sm_11 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu
