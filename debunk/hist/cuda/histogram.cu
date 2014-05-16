#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <helper_cuda.h>
#include <helper_functions.h>
#define BIN_COUNT 256 
//#define NUM_RUNS 5 
//#define NUM_TEST 10.0
#define BYTE_COUNT 25600
#define CHECK_ERR(x)                                    \
  if (x != cudaSuccess) {                               \
    fprintf(stderr,"%s in %s at line %d\n",             \
            cudaGetErrorString(err),__FILE__,__LINE__); \
    exit(-1);                                           \
  }

__global__ void
histogram( unsigned char *buffer,long size,unsigned int *histo ) {
  __shared__ unsigned int temp[BIN_COUNT];
  temp[threadIdx.x] = 0;
   __syncthreads();
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  int stride = blockDim.x * gridDim.x;
  while (i < size)
  {
          atomicAdd( &(temp[buffer[i]]), 1 );
              i += stride;
  }
  __syncthreads();
  atomicAdd( &(histo[threadIdx.x]), temp[threadIdx.x] );
  
}

void print(unsigned int *histo){
    int i;
    for(i=0;i<BIN_COUNT;i++){
        printf("%d\t",histo[i]);
    }
}
int main(int argc, char *argv[])
{
    if (argc != 5){
        printf("invalid parameters, use: <NUM_ELEMENTS> <NUM_THREADS> <NUM_TASKS> <NUM_TEST> \n");
    return -1;
    }
    unsigned char * h_data;
    unsigned int h_histogram[BIN_COUNT];
    unsigned char * d_data;
    unsigned int * d_histogram;
    unsigned int byteCount = atoi(argv[1])/atoi(argv[3]);//BYTE_COUNT;
    size_t size;
    cudaError_t err;

    //int NUM_RUNS = atoi(argv[1]);
    int NUM_THREADS = atoi(argv[2]);
    int NUM_TEST = atoi(argv[4]);
    
    StopWatchInterface *hTimer = NULL;
    //int iter;
    sdkCreateTimer(&hTimer);
    cudaDeviceProp prop;
    checkCudaErrors( cudaGetDeviceProperties( &prop, 0 ) );
    int blocks = prop.multiProcessorCount;
    //for(iter =0 ; iter < NUM_RUNS;iter++){
        srand (time(NULL));
        size = sizeof(unsigned char) * byteCount;
        h_data = (unsigned char *) malloc(sizeof(unsigned char) * byteCount);
        for (unsigned int i = 0; i < byteCount; i++)
        {
            h_data[i] = rand() % 256;
        }
        sdkResetTimer(&hTimer);
        sdkStartTimer(&hTimer);
        int j;
        for(j=0; j <  NUM_TEST; j++) {
            err=cudaMalloc((void **) &d_data, size);
            CHECK_ERR(err);
            err=cudaMalloc((void **) &d_histogram, sizeof(unsigned int) * BIN_COUNT);
            CHECK_ERR(err);
            err = cudaMemcpy(d_data,h_data,size,cudaMemcpyHostToDevice);
            CHECK_ERR(err);
            err = cudaMemcpy(d_histogram,h_histogram,sizeof(unsigned int) * BIN_COUNT, cudaMemcpyHostToDevice);
            CHECK_ERR(err);
            histogram<<<blocks,NUM_THREADS>>>(d_data,byteCount,d_histogram);
            cudaDeviceSynchronize();
            //Copy back the results from the device
            err = cudaMemcpy(h_histogram,d_histogram,sizeof(unsigned int) * BIN_COUNT,cudaMemcpyDeviceToHost);
            CHECK_ERR(err);
            //print(h_histogram);
            cudaFree(d_data);
            cudaFree(d_histogram);
        }
        sdkStopTimer(&hTimer);
        free(h_data);
        //unsigned int problem_size = byteCount * 4;
        double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / (double) NUM_TEST;
        //printf("%.4f\t%.4f\t%.5f",
        //(1.0e-6 * (double)problem_size / dAvgSecs),(3.0 * (double) byteCount/dAvgSecs), dAvgSecs);
        printf("%.5f\t",dAvgSecs);
        //byteCount = byteCount * 10;
    //}
    // Print timing information
    sdkDeleteTimer(&hTimer);
}
