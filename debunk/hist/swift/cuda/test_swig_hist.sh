swig -module hist hist.h
rm *.o
nvcc -arch=sm_20 -I ../../../../samples_include/inc/ -c -Xcompiler -fPIC hist.cu &&
nvcc -c -Xcompiler -fPIC -I /usr/include/tcl8.5 hist_wrap.c &&
nvcc -shared -o libhist.so hist_wrap.o hist.o &&
tclsh make-package.tcl > pkgIndex.tcl
