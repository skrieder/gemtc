#include "saxpy.c"
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <sys/time.h>

__global__
void cuda_saxpy(int num_threads, int n, float a, float *d_x, float *d_y)
{
  int i = threadIdx.x;

  // This loop performs 3 floating point ops per iteration.
  while(i<n){
    d_y[i] = a*d_x[i] + d_y[i];
    i = i+num_threads;
  }
}

int cuda_saxpy_launcher(int num_elements, int num_threads){
  // Var for error handling
  cudaError_t err = cudaSuccess;

  //  int num_elements = atoi(argv[1]);
  //  int num_threads = atoi(argv[2]);
  float a = 2.0;

  // Size for memory transfers
  int size = sizeof(float)*num_elements;

  // Seed rand
  srand (time(NULL));

  // Allocate arrays
  float *x = (float *)malloc(sizeof(float)*num_elements);
  float *y = (float *)malloc(sizeof(float)*num_elements);

  // Generate Random Arrays
  populateRandomFloatArray(num_elements, x);
  populateRandomFloatArray(num_elements, y);

  // Start the timer
  struct timeval tim;
  gettimeofday(&tim, NULL);
  double t1=tim.tv_sec+(tim.tv_usec/1000000.0);

  // Default to the first GPU
  err = cudaSetDevice(0);

  if (err != cudaSuccess){
    fprintf(stderr, "Failed to default to CUDA device 0! (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  // Allocate device memory
  float *d_x;
  float *d_y;
  err = cudaMalloc((void **) &d_x, sizeof(float)*num_elements);
  //  printf("DEBUG: cudaMalloc d_x size = %d\n", sizeof(float)*n);
  
  if (err != cudaSuccess){
    fprintf(stderr, "Failed to allocate device vector d_x (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  err = cudaMalloc((void **) &d_y, sizeof(float)*num_elements);

  if (err != cudaSuccess){
    fprintf(stderr, "Failed to allocate device vector d_y (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  // Copy data into d_x
  err = cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
  if (err != cudaSuccess){
    fprintf(stderr, "Failed to mem copy data into d_x (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  // Copy data into d_y
  err = cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);
  if (err != cudaSuccess){
    fprintf(stderr, "Failed to mem copy data into d_y (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  // Perform CUDA SAXPY
  cuda_saxpy<<<1,num_threads>>>(num_threads, num_elements, a, d_x, d_y);
  cudaDeviceSynchronize();
  
  // Copy result back
  err = cudaMemcpy(y, d_y, size, cudaMemcpyDeviceToHost);
  if (err != cudaSuccess){
    fprintf(stderr, "Failed to memcpy result back from device. (error code %s)!\n", cudaGetErrorString(err));
    fprintf(stderr, "The memcpy size was: %d\n", size);
    exit(EXIT_FAILURE);
  }

  // Print timing information
  gettimeofday(&tim, NULL);
  double t2=tim.tv_sec+(tim.tv_usec/1000000.0);
  printf("%.6lf\t", (((2*num_elements)/(t2-t1))/1000000)); // 1000000000 = 10^9, 1000000 = 10^6
  //printf("%d\t%d\t%.6lf\t", num_threads, n, t2-t1);

  // cpu free
  free(x);
  free(y);

  // cuda free
  err = cudaFree(d_x);
  if (err != cudaSuccess){
    fprintf(stderr, "Failed to free device memory d_x (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  err = cudaFree(d_y);
  if (err != cudaSuccess){
    fprintf(stderr, "Failed to free device memory d_y (error code %s)!\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }

  return 0;
}
