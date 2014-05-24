GeMTC - Image Convolution application 

- To execute the application manually, execute the below command
	- make
	- ./imageconv <IMAGE_WIDTH> <MASK_WIDTH>
	- ./imageconv 100 50
	

- To execute the application for complete test  from 1 KB to 12 MB, execute the below command
	- ./imageconv.sh
- To execute in RAVEN(K20)
        - qsub ../sites/raven/submit.sh
