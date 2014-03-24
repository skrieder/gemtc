#include <cuda.h>
#include <stdio.h>

void saxpy (float* X, float* Y, float* Z, int n);
float avg (float* arr, int n);

__global__
void saxpyKernel(float *x, float *y, float *z, float a, int n) {
  int id = blockIdx.x * blockDim.x + threadIdx.x;
  
  if (id < n)
    z[id] = a*x[id] + y[id];
}

int main () {
  int N = 1<<20;
  int size = N*sizeof(float);
  // Host input and output vectors
  float *h_x, *h_y, *h_z;
  
  // Allocate host memory for vecs
  h_x = (float*)malloc(size);
  h_y = (float*)malloc(size);
  h_z = (float*)malloc(size);
  
  int i;
  for (i = 0; i < N; i++) {
    h_x[i] = 1.0;
    h_y[i] = 2.0;
  }

  // Perform SAXPY on 1M elements
  saxpy(h_x, h_y, h_z, N);

  printf("AVG = %f\n", avg(h_z, N));
  
  // free host memory
  free(h_x);
  free(h_y);
  free(h_z);

  return 0;
}

void saxpy (float* X, float* Y, float* Z, int n) {
  //Device input and output vectors  
  float *d_x, *d_y, *d_z;
  int size = n*sizeof(float);

  // Allocate device memory
  cudaMalloc((void**)&d_x, size);
  cudaMalloc((void**)&d_y, size);
  cudaError_t z_err = cudaMalloc((void**)&d_z, size);
  if (z_err != cudaSuccess) {
    printf("%s in %s at line %d\n", cudaGetErrorString(z_err), __FILE__, __LINE__);}

  // Copy X and Y vectors to device
  cudaMemcpy(d_x, X, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, Y, size, cudaMemcpyHostToDevice);

  // number of threads per block
  int blockSize = 1024;
  // number of blocks
  //int gridSize = (int)ceil((float)n/blockSize);
  int gridSize = n/blockSize;

  saxpyKernel<<<gridSize, blockSize>>>(d_x, d_y, d_z, 2.0, n);

  // Copy z from device to host
  cudaMemcpy(Z, d_z, size, cudaMemcpyDeviceToHost);

  // free device memory
  cudaFree(d_x);
  cudaFree(d_y);
  cudaFree(d_z);
  
}

float avg (float* arr, int n) {
  int i;
  float total = 0;
  for (i = 0; i < n; i++) {
    total += arr[i];
  }
  return total / n;
}
