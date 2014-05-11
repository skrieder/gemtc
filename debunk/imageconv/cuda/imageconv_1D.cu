#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "../../saxpy/saxpy.c"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
//#define DEBUG 0

#define CHECK_ERR(x)                                    \
  if (x != cudaSuccess) {                               \
    fprintf(stderr,"%s in %s at line %d\n",             \
            cudaGetErrorString(err),__FILE__,__LINE__); \
    exit(-1);                                           \
  }   

__global__ void image_1D_convolution(float *M, float *N, float *C, int mask_width, int width,int num_threads)
{
int threadId = blockIdx.x * blockDim.x + threadIdx.x;
float value =0;
int start;
int index;
//this function includes 2 floating point operations
while(threadId < width)
{
start = threadId - (mask_width/2);
for(int i=0; i<mask_width;i++){
        index= start + i;
        if(index >=0 && index <width)
                value = value + N[index] * M[i];
}
threadId = threadId + num_threads;
C[threadId] = value;
}
}

void print(float* result,int size){
	printf("Printing array....\n");
	for(int i=0;i<size;i++){
		printf(" %f ", result[i]);
	}
printf("\n");
}

int main(int argc, char *argv[]){
  //mask_width, filter width
  int IMAGE_WIDTH, MASK_WIDTH,NUM_THREADS,FLAG;
  float *h_M, *h_N, *h_C;
  float *d_M, *d_N, *d_C;
  size_t size_M,size_N;
  cudaError_t err;
  if(argc!=5)
    {
      printf("This test requires two parameters:\n");
      printf("   int IMAGE_WIDTH, int MASK_WIDTH, int NUM_THREADS \n");
      printf("where  IMAGE_WIDTH is the number of pixels in an image in one dimensional\n");
      printf("       MASK_WIDTH is the width of the mask to be applied on the image\n");
      printf("       NUM_THREADS is the number of threads to be executed in parallel\n");
      printf("       FLAG to decide flops including data copy or not. 1 for flops with data copy and 0 for only execution of gpu function.\n");
      
      exit(1);
    }
  srand (time(NULL));
  IMAGE_WIDTH = atoi(argv[1]);
  MASK_WIDTH  = atoi(argv[2]);
  NUM_THREADS = atoi(argv[3]);
  FLAG = atoi(argv[4]);
  
  // allocate host
  size_M = sizeof(float) * MASK_WIDTH;
  size_N = sizeof(float) * IMAGE_WIDTH;
  h_N = (float *) malloc(size_N);
  h_M = (float *) malloc(size_M);
  h_C = (float *) malloc(size_N);
  
  // allocate device
  err=cudaMalloc((void **) &d_M, size_M);
  CHECK_ERR(err);
  err=cudaMalloc((void **) &d_N, size_N);
  CHECK_ERR(err);
  err=cudaMalloc((void **) &d_C, size_N);
  CHECK_ERR(err);
  
  // pop arrays
  populateRandomFloatArray(IMAGE_WIDTH,h_N);
  populateRandomFloatArray(MASK_WIDTH,h_M);
  
#ifdef DEBUG
  print(h_N,IMAGE_WIDTH);
  print(h_M, MASK_WIDTH);
#endif
  
  // Start the timer
  struct timeval tim;
  double t1,t2;
  
  if(FLAG){
    gettimeofday(&tim, NULL);
    t1=tim.tv_sec+(tim.tv_usec/1000000.0);
  }

  err = cudaMemcpy(d_M,h_M,size_M,cudaMemcpyHostToDevice);
  CHECK_ERR(err);
  err = cudaMemcpy(d_N,h_N,size_N, cudaMemcpyHostToDevice);
  CHECK_ERR(err);
  
  if(!FLAG){
    gettimeofday(&tim, NULL);
    t1=tim.tv_sec+(tim.tv_usec/1000000.0);
  }

  image_1D_convolution<<<1,NUM_THREADS>>>(d_M,d_N,d_C,MASK_WIDTH,IMAGE_WIDTH,NUM_THREADS);
  cudaDeviceSynchronize();
  if(!FLAG){
    gettimeofday(&tim, NULL);
    t2=tim.tv_sec+(tim.tv_usec/1000000.0);
  }

  //Copy back the results from the device
  //printf("%x %x %d\n", h_C, d_C, size_N);
  
  float * temp = (float *)malloc(size_N);
  //  err = cudaMemcpy((void *)h_C, (void *)d_C, size_N, cudaMemcpyDeviceToHost);
  err = cudaMemcpy((void *)temp, (void *)d_C, size_N, cudaMemcpyDeviceToHost);
  CHECK_ERR(err);
  //printf("AFTER COPY BACK!\n");

#ifdef DEBUG
  print(h_C,IMAGE_WIDTH);
#endif
  
  // free device
  cudaFree(d_C);
  cudaFree(d_M);
  cudaFree(d_N);
  
  if(FLAG){
    gettimeofday(&tim, NULL);
    t2=tim.tv_sec+(tim.tv_usec/1000000.0);
  }
  
  // Print timing information
  printf("%.4lf\t",(t2-t1));

  // free cpu
  free(h_M);
  free(h_N);
  free(h_C);
}
