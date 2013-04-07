# Compile the GEMTC framework into a shared library
echo 'Compiling the framework with NVCC'
nvcc -arch=sm_20 -o libtest.so --shared -Xcompiler -fPIC gemtc.cu

echo 'Compiling the different wrapper functions'
# Compile the gemtc_setup wrapper
gcc -std=c99 -I/usr/local/cuda/include -o bin/gemtc_setup -L. -ltest c_wrappers/gemtc_setup.c
# Compile the gemtc_run wrapper
gcc -std=c99 -I/usr/local/cuda/include -o bin/gemtc_run -L. -ltest c_wrappers/gemtc_run.c
# Compile the gemtc_cleanup wrapper
gcc -std=c99 -I/usr/local/cuda/include -o bin/gemtc_cleanup -L. -ltest c_wrappers/gemtc_cleanup.c
