#include "hist.h"
#define BIN_COUNT 256

double* hist(double *h_data,int byteCount){
	//unsigned char * h_data;
 	unsigned int h_histogram[BIN_COUNT];
 	//unsigned char * d_data;
 	//unsigned int byteCount = 25600;
 	size_t size; 
 	struct timeval tim;
 	double t1,t2;
 	int iter, i;
 	int NUM_RUNS = 1;
 	
	for(iter =0 ; iter< NUM_RUNS;iter++){
 	srand (2009);
 	//size = sizeof(unsigned char) * byteCount;
 	/*h_data = (unsigned char *) malloc(sizeof(unsigned char) * byteCount);
 	for (i = 0; i < byteCount; i++)
 	{
        	h_data[i] = rand() % 256;
 	}
 	*/
	gettimeofday(&tim, NULL);
 	t1=tim.tv_sec+(tim.tv_usec/1000000.0);
	int j,k;
 	
	//for(j=0; j < TEST_RUN; j++) {
 	for(k=0;k<byteCount;k++){
		h_histogram[(int)h_data[k]]++;
	}
 	//}	
  	
	gettimeofday(&tim, NULL);
  	t2=tim.tv_sec+(tim.tv_usec/1000000.0);
 	//free(h_data); 
 	
	double dAvgSecs = (t2-t1);

	unsigned int problem_size = byteCount * 4;
        printf("%u\t%.4f\t%.5f\n",
        problem_size,(1.0e-6 * (double)problem_size / dAvgSecs), dAvgSecs);
 	byteCount = byteCount * 10;
 
	}
	double* result = malloc(sizeof(double));
  	result[0] = 0;
  	return result;
}
