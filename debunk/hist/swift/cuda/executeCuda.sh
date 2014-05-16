nvcc -arch=sm_20 -I ../../../../samples_include/inc/ -c hist.cu
nvcc -arch=sm_20 -I ../../../../samples_include/inc/ -c simple.cu
nvcc -o hist.x hist.o simple.o
time ./hist.x
rm *.o
