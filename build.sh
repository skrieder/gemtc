# Compile the GEMTC framework into a shared library
echo 'Compiling the framework with NVCC'
nvcc -arch=sm_20 -o libgemtc.so --shared -Xcompiler -fPIC gemtc.cu
