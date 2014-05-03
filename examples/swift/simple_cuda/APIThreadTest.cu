#include <stdio.h>
#include <stdlib.h>
#include "AddSleep.cu"
#include <cuda.h>
#include <cuda_runtime.h>


int NUM_THREADS;
int JOBS_PER_THREAD;
int QUEUE_SIZE=12800;
int SLEEP_TIME;
int MALLOC_SIZE;
int LOOP_SIZE;

extern "C"
void sleep_wrapper(int SLEEP_TIME);

/*
int main(int argc, char **argv){
  printf("Starting AddSleep Test\n");
  if(argc>4){
    NUM_THREADS = atoi(argv[1]);
    JOBS_PER_THREAD = atoi(argv[2]);
    SLEEP_TIME = atoi(argv[3]);
    MALLOC_SIZE = atoi(argv[4]);
    LOOP_SIZE = atoi(argv[5]);
  }else{
    printf("This test requires five parameters:\n");
    printf("   int NUM_THREADS, int JOBS_PER_THREAD, int SLEEP_TIME, int MALLOC_SIZE, int LOOP_SIZE\n");
    printf("where  NUM_THREADS is the number of seperate threads that will be sending work into gemtc\n");
    printf("       JOBS_PER_THREAD is the number of tasks that a given thread will submit to gemtc\n");
    printf("       SLEEP_TIME is the parameter that will be given to each AddSleep micro-kernel, in microseconds\n");
    printf("       MALLOC_SIZE is the amount of memory that will be allocated and transfered with each sleep\n");
    printf("                   This number must be a multiple of 4, to comply with cuda's memory requirements\n");
    printf("       LOOP_SIZE is the number of tasks a thread will submit to gemtc before waiting for results\n");
    exit(1);
  }
  sleep_wrapper(SLEEP_TIME);
  return 0;
}
*/
void sleep_wrapper(int SLEEP_TIME){
  
  int nkernels = 1;               // number of concurrent kernels                                     
  int nstreams = nkernels + 1;    // use one more stream than concurrent kernel                       
  int nbytes = nkernels * sizeof(clock_t);   // number of data bytes                                  
  float kernel_time = SLEEP_TIME; // time the kernel should run in ms                                 
  float elapsed_time;   // timing variables                                                           
  int cuda_device = 0;
  
  int deviceCount;
  cudaGetDeviceCount(&deviceCount);
  if (deviceCount == 0) {
    fprintf(stderr, "error: no devices supporting CUDA.\n");
    exit(EXIT_FAILURE);
  }
  int dev = 0;
  cudaSetDevice(dev);
  cudaDeviceProp prop;
  if (cudaGetDeviceProperties(&prop, dev) == cudaSuccess){
    printf("Using device %d:\n", dev);
    printf("%s; global mem: %dB; compute v%d.%d; clock: %d kHz\n",
	   prop.name, (int)prop.totalGlobalMem, (int)prop.major, 
	   (int)prop.minor, (int)prop.clockRate);
  }
  
  clock_t time_clocks = (clock_t)(kernel_time * (int)prop.clockRate);
  
  // allocate host memory                                                                             
  clock_t *a = 0;                     // pointer to the array data in host memory                     
  // allocate device memory                                                                           
  clock_t *d_a = 0;             // pointers to data and init value in the device memory              
  cudaMalloc((void **)&d_a, nbytes);
  
  // run the task
  //  wrapAddSleep<<<1,1>>>(d_sleepTime);
  clock_block<<<1,1>>>(&d_a[0], time_clocks);
  
  // wait
  cudaDeviceSynchronize();
  
  // return
  // return 0;
}
