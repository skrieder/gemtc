#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "../saxpy/saxpy.c"
#include <stdio.h>
#include <stdlib.h>
#define CHECK_ERR(x)                                    \
  if (x != cudaSuccess) {                               \
    fprintf(stderr,"%s in %s at line %d\n",             \
            cudaGetErrorString(err),__FILE__,__LINE__); \
    exit(-1);                                           \
  }   

__global__ void image_1D_convolution(float *M, float *N, float *C, int mask_width, int width)
{
int threadId = blockIdx.x * blockDim.x + threadIdx.x;
float value =0;
int start = threadId - (mask_width/2);
int index;
//this function includes 2 floating point operations
for(int i=0; i<width;i++){
	index= start + i;
	if(index >=0 && index <width)
		value = value + N[index] * M[i];
}
C[threadId] = value;	
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
int IMAGE_WIDTH, MASK_WIDTH;
float *h_M, *h_N, *h_C;
float *d_M, *d_N, *d_C;
size_t size_M,size_N;
cudaError_t err;
if(argc!=3)
{
	printf("This test requires two parameters:\n");
    printf("   int IMAGE_WIDTH, int MASK_WIDTH \n");
    printf("where  IMAGE_WIDTH is the number of pixels in an image in one dimensional\n");
    printf("       MASK_WIDTH is the width of the mask to be applied on the image\n");
	exit(1);
}
IMAGE_WIDTH = atoi(argv[1]);
MASK_WIDTH  = atoi(argv[2]);
size_M = sizeof(float) * MASK_WIDTH;
size_N = sizeof(float) * IMAGE_WIDTH;
h_N = (float *) malloc(size_N);
h_M = (float *) malloc(size_M);
h_C = (float *) malloc(size_N);

err=cudaMalloc((void **) &d_M, size_M);
CHECK_ERR(err);
err=cudaMalloc((void **) &d_N, size_N);
CHECK_ERR(err);
err=cudaMalloc((void **) &d_C, size_N);
CHECK_ERR(err);

populateRandomFloatArray(IMAGE_WIDTH,h_N);
populateRandomFloatArray(MASK_WIDTH,h_M);

print(h_N,IMAGE_WIDTH);
print(h_M, MASK_WIDTH);

err = cudaMemcpy(d_M,h_M,size_M,cudaMemcpyHostToDevice);
CHECK_ERR(err);
err = cudaMemcpy(d_N,h_N,size_N, cudaMemcpyHostToDevice);
CHECK_ERR(err);

image_1D_convolution<<<1,256>>>(d_M,d_N,d_C,MASK_WIDTH,IMAGE_WIDTH);
cudaDeviceSynchronize();

//Copy back the results from the device
err = cudaMemcpy(h_C,d_C,size_N,cudaMemcpyDeviceToHost);
CHECK_ERR(err);
print(h_C,IMAGE_WIDTH);
cudaFree(d_C);
cudaFree(d_M);
cudaFree(d_N);


free(h_M);
free(h_N);
free(h_C);
printf("Number of floating point operations: %d\n", IMAGE_WIDTH*2);
}
