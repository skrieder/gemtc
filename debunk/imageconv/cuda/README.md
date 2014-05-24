CUDA - Image Convolution application 

- To execute the application manually, execute the below command
	- make
	- ./imageconv <IMAGE_WIDTH> <MASK_WIDTH> <NUM_THREADS>
	- ./imageconv 100 50 1024

- To execute the application for complete test from 1 - 1024 threads and different problem size, execute the below command
	- ./imageconv.sh
- To execute in RAVEN(K20)
	- qsub ../sites/raven/submit.sh
