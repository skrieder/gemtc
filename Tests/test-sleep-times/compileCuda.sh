#1
nvcc -arch=sm_11 -c -Xcompiler -fPIC sleep.cu
#2
nvcc -arch=sm_11 --shared -o libsleep.so sleep.o 

#nvcc -arch=sm_11 -o libsleep.so --shared -Xcompiler -fPIC sleep.cu
