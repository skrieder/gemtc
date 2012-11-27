#include <stdio.h>
#include <cuda_runtime.h>
#include <pthread.h>

cudaStream_t stream_dataIn, stream_dataOut, stream_kernel;

pthread_mutex_t memcpyLock;
pthread_mutex_t enqueueLock;
pthread_mutex_t dequeueLock;

int *d_kill;

#include "DataMovement.cu"
#include "malloc/GemtcMalloc.cu"
#include "Queues/QueueJobs.cu"
#include "SuperKernel.cu"

Queue d_newJobs, d_finishedJobs;
/////////////////////
//Utility Functions//
/////////////////////
void *moveToCuda(void *val, int size){
  void *ret = gemtcMalloc(size);
  cudaSafeMemcpy(ret, val, size, 
                 cudaMemcpyHostToDevice, stream_dataIn, 
                 "in moveToCuda of run()");
  return ret;
}
void *moveFromCuda(void *val, int size){
  void *ret = malloc(size);
  cudaSafeMemcpy(ret, val, size, 
                 cudaMemcpyDeviceToHost, stream_dataOut, 
                 "in moveFromCuda of run()");
  return ret;
}

/////////////////
//API Functions//
/////////////////
extern "C"
void setupGemtc(int QueueSize){
  pthread_mutex_init(&memcpyLock, NULL);
  pthread_mutex_init(&enqueueLock, NULL);
  pthread_mutex_init(&dequeueLock, NULL);

  int warp_size = 32;

  int warps = 8;
  int blocks = 14;

  dim3 threads(warp_size*warps, 1, 1);
  dim3 grid(blocks, 1, 1);

  cudaStreamCreate(&stream_kernel);
  cudaStreamCreate(&stream_dataIn);
  cudaStreamCreate(&stream_dataOut);
  
  d_newJobs = CreateQueue(QueueSize);
  d_finishedJobs = CreateQueue(QueueSize);

  int temp = 0;
  d_kill = (int *) moveToCuda((void *)&temp, sizeof(int));

  cudaDeviceSynchronize();

//Launch the super kernel
  superKernel<<< grid, threads, 0, stream_kernel>>>
             (d_newJobs, d_finishedJobs, d_kill);
}


int ID =0;
extern "C"
void *run(int Type, int Threads, void *host_params, int size_params){
  JobPointer h_JobDescription = (JobPointer) malloc(sizeof(JobDescription));
  h_JobDescription->JobType = Type;
  h_JobDescription->numThreads = Threads;
  h_JobDescription->params = moveToCuda(host_params, size_params);

  pthread_mutex_lock(&enqueueLock);  //Start Critical Section
  int MyID = ID++;
  h_JobDescription->JobID = MyID;

  EnqueueJob(h_JobDescription, d_newJobs);
  pthread_mutex_unlock(&enqueueLock); //End Critical Section
  //  printf("Finished enqueue #%d\n", MyID);

  int first = 1;
  while(h_JobDescription->JobID!=MyID || first){
    pthread_yield();
    pthread_mutex_lock(&dequeueLock);
    h_JobDescription = FrontResult(d_finishedJobs);
    if(h_JobDescription->JobID==MyID)DequeueResult(d_finishedJobs);
    pthread_mutex_unlock(&dequeueLock);
    first = 0;
    //printf("Current front:%d  MyID:%d\n", h_JobDescription->JobID, MyID);
  }
  //printf("Recieved result on Job #%d\n", MyID);
  
  return moveFromCuda(h_JobDescription->params, size_params); 
}

extern "C"
void cleanupGemtc(){
  int temp=1;
  cudaSafeMemcpy(&temp, d_kill, sizeof(int), cudaMemcpyHostToDevice, 
                 stream_dataIn, "Writing the kill command to SuperKernel");

  DisposeQueue(d_newJobs);

  DisposeQueue(d_finishedJobs);

  cudaStreamDestroy(stream_kernel);
  cudaStreamDestroy(stream_dataIn);
  cudaStreamDestroy(stream_dataOut);

  pthread_mutex_destroy(&memcpyLock);
  pthread_mutex_destroy(&enqueueLock);
  pthread_mutex_destroy(&dequeueLock);
}
