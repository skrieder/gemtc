CC=nvcc
CFLAGS=-arch=sm_20

mkdir -p gemtc_imogen_bin
$CC $CFLAGS -o gemtc_imogen_bin/ArrayAtomicTest cuda_src/ArrayAtomicTest.cu
$CC $CFLAGS -o gemtc_imogen_bin/ArrayRotateTest cuda_src/ArrayRotateTest.cu
$CC $CFLAGS -o gemtc_imogen_bin/FluidWTest cuda_src/FluidWTest.cu
$CC $CFLAGS -o gemtc_imogen_bin/freezeAndPtotTest cuda_src/freezeAndPtotTest.cu
$CC $CFLAGS -o gemtc_imogen_bin/FluidTVDTest cuda_src/FluidTVDTest.cu
$CC $CFLAGS -o gemtc_imogen_bin/memory_bugger cuda_src/memory_bugger.cu
$CC $CFLAGS -o gemtc_imogen_bin/Pi cuda_src/Pi.cu


$CC $CFLAGS -o host_bin/ArrayAtomic host_src/ArrayAtomic.c
$CC $CFLAGS -o host_bin/ArrayRotate host_src/ArrayRotate.c
$CC $CFLAGS -o host_bin/FluidW host_src/FluidW.c
$CC $CFLAGS -o host_bin/freezeAndPtot host_src/freezeAndPtot.c
$CC $CFLAGS -o host_bin/FluidTVD host_src/FluidTVD.c
$CC $CFLAGS -o host_bin/Pi host_src/Pi.c
