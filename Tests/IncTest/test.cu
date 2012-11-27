#include <stdio.h>
#include <cuda_runtime.h>
#include <sys/time.h>

#include "Kernels/incSuperKernel.cu"

#include <pthread.h>

/////////////////////////////////////////////////////////////////
// Global Variables
/////////////////////////////////////////////////////////////////

void printAnyErrors()
{
  cudaError_t e = cudaGetLastError();
  printf("CUDA error:  %s \n", cudaGetErrorString(e));
  
}

////////////////////////////////////////////////////////////////////
// The Main
////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  cudaStream_t stream_kernel, stream_dataIn, stream_dataOut;
  cudaStreamCreate(&stream_kernel);
  cudaStreamCreate(&stream_dataIn);
  cudaStreamCreate(&stream_dataOut);  //currently these arent used



  int size = 5;

  int* h_init = (int*)malloc((size+1)*sizeof(int));
  int* h_result = (int*)malloc((size+1)*sizeof(int));

  int* d_init;
  cudaMalloc(&d_init, (size+1)*sizeof(int));
  int* d_result;
  cudaMalloc(&d_result, (size+1)*sizeof(int));

  h_init[0]=0;  //set the data ready flag to false
  cudaMemcpyAsync(d_init, h_init, sizeof(int), cudaMemcpyHostToDevice,stream_dataIn);
  cudaStreamSynchronize(stream_dataIn);

  h_result[0]=0;  //set the data ready flag to false
  cudaMemcpyAsync(d_result, h_result, sizeof(int), cudaMemcpyHostToDevice,stream_dataOut);
  cudaStreamSynchronize(stream_dataOut);

  dim3 threads(32, 1);
  dim3 grid(1, 1);

  printf("launching SuperKernel\n");

// call the cudaMatrixMul cuda function
  superKernel<<< grid, threads, 0, stream_kernel>>>(d_init, size, d_result);

//PRINT HERE
  printAnyErrors();

//Make inputs and transfer them
  int j;
  for(j=1;j<size+1;j++)h_init[j] = j;

  printf("launching cudaMemcpy Data\n");

  cudaMemcpyAsync(&d_init[1], &h_init[1], size*sizeof(int), cudaMemcpyHostToDevice, stream_dataIn);
  cudaStreamSynchronize(stream_dataIn); 

//PRINT HERE
  printAnyErrors();

//Mark flag as ready
  printf("launching cudaMemcpy Flag\n");

  h_init[0]=7;
  cudaMemcpyAsync(d_init, h_init, sizeof(int), cudaMemcpyHostToDevice,stream_dataIn);
  cudaStreamSynchronize(stream_dataIn);
 

//wait for result flag to be on
  while(h_result[0]==0) { cudaMemcpyAsync(h_result, d_result, sizeof(int), cudaMemcpyDeviceToHost, stream_dataOut); 
                          cudaStreamSynchronize(stream_dataOut); 
                          printf("got value h_result[0]:  %d\n", h_result[0]); }
//PRINT HERE
  printAnyErrors();

//Get and print results
  cudaMemcpyAsync(&h_result[1], &d_result[1], size*sizeof(int), cudaMemcpyDeviceToHost, stream_dataOut);
  cudaStreamSynchronize(stream_dataOut); 
  int i;
  for(i=0; i<size; i++) printf("intial value: %d\t final value: %d\n", h_init[i+1], h_result[i+1]);

//PRINT HERE
  printAnyErrors();

  return 0;    
}







