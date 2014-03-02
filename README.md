These are the files and dirs in the gemtc project:

/Swift Integration
===
Adding a GeMTC app into swift is a multistep process.
Before adding into Swift make sure that you have a C driver program testing the GeMTC code.

1. Create GeMTC <app> driven by C
2. Add GeMTC <app> to gemtc large switch statement

Some notes that need to cleaned up:
# Notes on adding new apps
# Adding new APPS step #1 add to switch on subcommand
I create a new entry in the switch command by duplicating the sleep catch:
These lines need to change:
set sup [ gemtc::gemtc_sleep_begin {*}$args ]
if { [ catch { gemtc_put_sleep $rule_id $command $sup } e ] } {
===

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