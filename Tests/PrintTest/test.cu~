#include <stdio.h>
#include <cuda_runtime.h>
#include <sys/time.h>

#include "kernel.cu"
#include <pthread.h>

/////////////////////////////////////////////////////////////////
// Helper Functions
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
  cudaStreamCreate(&stream_dataOut);

  //flags will be zero until they are ready then non-zero
  int* d_flagIn;
  cudaMalloc(&d_flagIn, sizeof(int));
  int* d_flagOut;
  cudaMalloc(&d_flagOut, sizeof(int));

  int default_flag = 0;

  cudaMemcpyAsync(d_flagIn, &default_flag, sizeof(int), cudaMemcpyHostToDevice,stream_dataIn);
  cudaStreamSynchronize(stream_dataIn);

  cudaMemcpyAsync(d_flagOut, &default_flag, sizeof(int), cudaMemcpyHostToDevice,stream_dataOut);
  cudaStreamSynchronize(stream_dataOut);

  dim3 threads(32, 1);
  dim3 grid(1, 1);

  printf("launching SuperKernel\n");

// call the cudaMatrixMul cuda function
  superKernel<<< grid, threads, 0, stream_kernel>>>(d_flagIn, d_flagOut);

//PRINT HERE
  printAnyErrors();



//Mark flag as ready
  printf("launching cudaMemcpy d_flagIn\n");

  int start_flag = 7;
  cudaMemcpyAsync(d_flagIn, &start_flag, sizeof(int), cudaMemcpyHostToDevice,stream_dataIn);
  cudaStreamSynchronize(stream_dataIn);
 
  printf("starting wait for d_flagOut\n");

//wait for result flag to be on
  int done_flag=0;
  while(done_flag == 0) { cudaMemcpyAsync(&done_flag, d_flagOut, sizeof(int), cudaMemcpyDeviceToHost, stream_dataOut); 
                          cudaStreamSynchronize(stream_dataOut); 
                          printf("got value d_flagOut:  %d\n", done_flag); 
                        }
//PRINT HERE
  printAnyErrors();

  return 0;    
}







