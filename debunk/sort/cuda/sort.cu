#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <helper_cuda.h>
#include <helper_functions.h>
#define NUM_RUNS 6 
#define BYTE_COUNT 1000
#define NUM_TEST 10
#define CHECK_ERR(x)                                    \
  if (x != cudaSuccess) {                               \
    fprintf(stderr,"%s in %s at line %d\n",             \
            cudaGetErrorString(err),__FILE__,__LINE__); \
    exit(-1);                                           \
  }


// Forward declaration of partition_by_bit(), called by sort()
__device__ void partition_by_bit(unsigned int *values, unsigned int bit,int n);

__global__ void sort(unsigned int *values,int n)
{
    int  bit;
    unsigned int i = (blockDim.x * blockIdx.x) + threadIdx.x;
    if(i < n) {
   if(threadIdx.x == 64)
    printf("%d - %d\n",i, blockIdx.x); 
    for( bit = 0; bit < 32; ++bit )
    {
        partition_by_bit(values, bit,n);
        __syncthreads();
    }
    
}
}

template<class T>
__device__ T plus_scan(T *x,int n)
{
    unsigned int i = blockDim.x * blockIdx.x + threadIdx.x;

    //unsigned int i = threadIdx.x; // id of thread executing this instance

    unsigned int num = blockDim.x;// * (blockIdx.x +1);  // total number of threads in this block
    unsigned int offset;          // distance between elements to be added
   if(i < n){ 
   for( offset = 1; offset < num; offset *= 2) {
        T t;

        if ( i >= offset ) 
            t = x[i-offset];
        
        __syncthreads();

        if ( i >= offset ) 
            x[i] = t + x[i];      // i.e., x[i] = x[i] + x[i-1]

        __syncthreads();
    }
    //printf("Plus Scan - %d \n", x[i]);
    return x[i];
}
return 0;
}

__device__ void partition_by_bit(unsigned int *values, unsigned int bit,int n)
{
    unsigned int i = blockDim.x * blockIdx.x + threadIdx.x;
    unsigned int size = blockDim.x* (blockIdx.x + 1);
    if(i < n){
    unsigned int x_i = values[i];          // value of integer at position i
    unsigned int p_i = (x_i >> bit) & 1;   // value of bit at position bit

    values[i] = p_i;  

    // Wait for all threads to finish this.
    __syncthreads();

    unsigned int T_before = plus_scan(values,n);
    if(size -1 < n){
    unsigned int T_total  = values[size-1];
    unsigned int F_total  = size - T_total;
    __syncthreads();
	
    if (p_i)
        values[T_before-1 + F_total] = x_i;
    else
        values[i - T_before] = x_i;
   }
}
    //printf("BlockId Id %d - %d - %d \n", blockIdx.x,i,size);
    
}
void print(unsigned int *values, int size){
   for(int i=0; i < size; i++){
       printf("%d\n", values[i]);

   }
}
int main(int argc, char *argv[])
{
    unsigned int * h_data;
    unsigned int * d_data;

    size_t size;
    cudaError_t err;
    StopWatchInterface *hTimer = NULL;
    int iter;
    sdkCreateTimer(&hTimer);
    cudaDeviceProp prop;
    checkCudaErrors( cudaGetDeviceProperties( &prop, 0 ) );
    int blocks = prop.multiProcessorCount;
    int byteCount = BYTE_COUNT;
    cudaDeviceProp devProp;
    cudaGetDeviceProperties(&devProp, 0);
    int numthreads = devProp.maxThreadsPerBlock;
    for(iter =0 ; iter < NUM_RUNS;iter++){
        srand (time(NULL));
        size = sizeof(unsigned int) * byteCount;
        h_data = (unsigned int *) malloc(sizeof(unsigned int) * byteCount);
        for (int i = 0; i < byteCount; i++)
        {
            h_data[i] = rand() % 1024;
//  	    printf("Rand %d\n", h_data[i]);
        }
        sdkResetTimer(&hTimer);
        sdkStartTimer(&hTimer);
        int j;
        for(j=0; j <  NUM_TEST; j++) {
            err=cudaMalloc((void **) &d_data, size);
            CHECK_ERR(err);
            
            err = cudaMemcpy(d_data,h_data,size,cudaMemcpyHostToDevice);
            CHECK_ERR(err);
              
            sort<<<blocks,numthreads>>>(d_data, byteCount);
            cudaDeviceSynchronize();
            //Copy back the results from the device
            err = cudaMemcpy(h_data,d_data,size,cudaMemcpyDeviceToHost);
            CHECK_ERR(err);
        //    print(h_data,byteCount);
	    		
            cudaFree(d_data);
            
        }
        sdkStopTimer(&hTimer);
        free(h_data);
        unsigned int problem_size = byteCount * 4;
        double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / NUM_TEST;
        printf("%u\t%.4f\t%.5f\n",
        byteCount,(1.0e-6 * (double)problem_size / dAvgSecs), dAvgSecs);
        byteCount = byteCount * 10;
    }
    // Print timing information
    sdkDeleteTimer(&hTimer);
}

