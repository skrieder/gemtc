These are the files and dirs in the gemtc project:

/CPUAPI
===
Same idea as dummy api. CPU may actually launch tasks on CPU, need to double check on this.
===
DataMovement.cu

/Kernels
===
This dir contains the micro-kernels found in gemtc. Micro-kernels are precompiled applications built into gemtc that are available for workers to execute.
===

/MICAPI
===
Same idea as /XEONPHI but may be interface to this need to double check.
===

Makefile
===
Build file for various tests, needs to be fixed.
===

/Queues
===
The queue implementations found in gemtc.
===
README.md
SuperKernel.cu

/Tests
===
This dir contains gemtc performance tests and micro-kernel testing scripts.
===

apps

/bin
===
Contains binary executables.
===


build.sh
===
This file builds a .so file of the latest gemtc code. Maybe this should live somewhere else.
===

c_wrapper_join
===
Obsolute, may move soon.
===


/documentation
===
Contains documentation that can be quickly published to the web.
===

/dummyAPI
===
A CPU implementation of gemtc, tasks don't touch GPU.
===

gemtc.cu
===
Incorporates the gemtc api.
===

gemtc.o
gemtc.so
libgemtc.so
===
Some of the latest shared object files, shouldn't live in root, will move soon.
===

/malloc
===
Dir supporting dynamic memory allocation.
===

misc

/papers
===
Not always up to date, but latest paper drafts and pdfs.
===

/xeonphi
===
Skeleton framework for gemtc on Xeon Phi.
===