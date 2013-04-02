#include <stdio.h>

//This file will run nkernel many kernels concurrently and each
//  of them will sleep for kernel_time ms. These two numbers can
//  be passed in as parameters, currently just list the two integers
//  in the command line with nkernels first then kernel_time.

//This file is intended to be used for measuring the overhead in creating
//  kernels and using GPGPUs

// This is a kernel that does no real work but runs at least for a specified number of clocks
__global__ void clock_block(int kernel_time, int clockRate)
{ 
  int finish_clock;
  int start_time;
  for(int temp=0; temp<kernel_time; temp++){
    start_time = clock();
    finish_clock = start_time + clockRate;
    bool wrapped = finish_clock < start_time;
    while( clock() < finish_clock || wrapped){
      wrapped = clock()>0 && wrapped;
    }
  }
}

int main(int argc, char **argv)
{
  //Default values
  int nkernels = 1;              // number of concurrent kernels
  int nstreams = nkernels + 1;    // use one more stream than concurrent kernel
  int kernel_time = 1000;         // time the kernel should run in ms
  int cuda_device = 0;

  if( argc>2 ){
    nkernels = atoi(argv[1]);       //could be used to pass in parameters
    kernel_time = atoi(argv[2]);
  }
  if( argc<2 ){
    printf("Wrong number of params used, running with defualts.\n");
    printf("Nkernels is:%d Sleeptime is: %d\n", nkernels, kernel_time);
    printf("./sleep <Number of Concurrent Kernels> <Sleep time in ms>\n");
  }

  //Getting device information, because we need clock_rate later
  cudaDeviceProp deviceProp;
  cudaGetDevice(&cuda_device);
  cudaGetDeviceProperties(&deviceProp, cuda_device);

  // allocate and initialize an array of stream handles
  cudaStream_t *streams = (cudaStream_t*) malloc(nstreams * sizeof(cudaStream_t));
  for(int i = 1; i < nstreams; i++){
    cudaStreamCreate(&(streams[i]));
  }
  //////////////////////////////////////////////////////////////////////
  int clockRate = deviceProp.clockRate; 

  printf("Clockrate is:%d\n", clockRate);
  //I am starting this at i=1 because the default stream is 0.
  for( int i=1; i<nkernels+1; ++i){
      //printf("starting kernel:  %d\n", i);
      clock_block<<<1,1,1,streams[i]>>>(kernel_time, clockRate);
    }

  //Find an errors that the gpu kernels had
  cudaError cuda_error = cudaDeviceSynchronize();
  if(cuda_error==cudaSuccess){
  }else{
    printf("CUDA Error: %s\n", cudaGetErrorString(cuda_error));
    return 1;
  }

  // release resources
  for(int i = 1; i < nstreams; i++)
    cudaStreamDestroy(streams[i]); 
 
  free(streams);
  return 0;    
}
