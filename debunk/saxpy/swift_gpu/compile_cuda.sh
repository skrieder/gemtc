# Compile the GEMTC framework into a shared library
echo 'Compiling the framework with NVCC'
nvcc -arch=sm_20 -o libsaxpy.so --shared -Xcompiler -fPIC ../saxpy.cu
