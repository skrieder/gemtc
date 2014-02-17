# Compile the GEMTC framework into a shared library
echo 'Compiling the framework with NVCC'
nvcc -arch=sm_20 -o libsleep.so --shared -Xcompiler -fPIC APIThreadTest.cu
