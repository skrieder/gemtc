#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "../../saxpy/saxpy.c"

int main(int argc, char *argv[])
{
        
        int IMAGE_WIDTH, MASK_WIDTH;
        float *h_M, *h_N,*h_C;
        size_t size_M,size_N;
		
		
          if(argc!=3)
		{
		  printf("This test requires two parameters:\n");
		  printf("   int IMAGE_WIDTH, int MASK_WIDTH \n");
		  printf("where  IMAGE_WIDTH is the number of pixels in an image in one dimensional\n");
		  printf("       MASK_WIDTH is the width of the mask to be applied on the image\n");
		  exit(1);
		}
        struct timeval tim;
        double t1,t2;
        int iter, i;

		IMAGE_WIDTH = atoi(argv[1]);
		MASK_WIDTH  = atoi(argv[2]);
        srand (2009);
        size_M = sizeof(float) * MASK_WIDTH;
		size_N = sizeof(float) * IMAGE_WIDTH;
		h_N = (float *) malloc(size_N);
		h_M = (float *) malloc(size_M);
		h_C = (float *) malloc(size_N);
		populateRandomFloatArray(IMAGE_WIDTH,h_N);
		populateRandomFloatArray(MASK_WIDTH,h_M);

        gettimeofday(&tim, NULL);
        t1=tim.tv_sec+(tim.tv_usec/1000000.0);
        int j,k;

		for(k=0;k<IMAGE_WIDTH;k++)
		{
		float value =0;
		int start;
		int index;
		start = k - (MASK_WIDTH/2);
		for(int i=0; i<MASK_WIDTH;i++){
			index= start + i;
			if(index >=0 && index <IMAGE_WIDTH)
					value = value + h_N[index] * h_M[i];
		}
		h_C[k] = value;
		}
        gettimeofday(&tim, NULL);
        t2=tim.tv_sec+(tim.tv_usec/1000000.0);
        free(h_M);
  free(h_N);
  free(h_C);
	double dAvgSecs = (t2-t1);
        printf("%.4f\n", dAvgSecs);
}

