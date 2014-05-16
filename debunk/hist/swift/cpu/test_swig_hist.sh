swig -module hist hist.h
rm *.o
gcc -c -fPIC  hist.c &&
gcc -c -fPIC -I /usr/include/tcl8.5 hist_wrap.c &&
gcc -shared -o libhist.so hist_wrap.o hist.o &&
tclsh make-package.tcl > pkgIndex.tcl
