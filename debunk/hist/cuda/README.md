CUDA - Histogram application 

- To execute the application manually, execute the below command
	- make
	- ./histogram <NUM_ELEMENTS> <NUM_THREADS> <NUM_TASKS> <NUM_TEST>
	- ./histogram 5 256 1 10
	- For Histogram, since 256-bin histogram is implemented. Use num_threads between 1 - 256

- To execute the application for complete test from 1 - 256 threads and problem size from 1 KB to 12 MB, execute the below command
	- ./compileScript.sh

