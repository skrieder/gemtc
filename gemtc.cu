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

/*
This file contains the functions that make up the API to gemtc
They are:
*** Initialize/Deconstruct ***
  gemtcSetup()
  gemtcCleanup()

*** EnQueue/DeQueue Tasks  ***
  gemtcBlockingRun()
  gemtcPush()
  gemtcPoll()

*** Memory Transfer Calls  ***
  gemtcMemcpyHostToDevice()
  gemtcMemcpyDeviceToHost()

****Memory Management Calls***
  gemtcGPUMalloc()
  gemtcGPUFree()
 */


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
void gemtcSetup(int QueueSize){
  //initialize locks
  pthread_mutex_init(&memcpyLock, NULL);
  pthread_mutex_init(&enqueueLock, NULL);
  pthread_mutex_init(&dequeueLock, NULL);
  pthread_mutex_init(&memoryListLock, NULL);

  //Default sizes for SuperKernel
  // Eventually this should read from a config file
  int warp_size = 32;
  int warps = 32;
  int blocks = 7;

  dim3 threads(warp_size*warps, 1, 1);
  dim3 grid(blocks, 1, 1);

  //Init Streams for the SuperKernel and various memory copies
  cudaStreamCreate(&stream_kernel);
  cudaStreamCreate(&stream_dataIn);
  cudaStreamCreate(&stream_dataOut);
  
  //Initialize Device Memory with Queues
  d_newJobs = CreateQueue(QueueSize);
  d_finishedJobs = CreateQueue(QueueSize);

  //Initialize kill flag in device Memory
  int temp = 0;
  d_kill = (int *) moveToCuda((void *)&temp, sizeof(int));

  cudaDeviceSynchronize();

//Launch the super kernel
  superKernel<<< grid, threads, 8192, stream_kernel>>>  //8192 = 8kBytes of shared Memory
             (d_newJobs, d_finishedJobs, d_kill);
}


extern "C"
void gemtcBlockingRun(int Type, int Threads, int ID, void *d_params){
  //This funcyion will enqueue the given task to the device
  //Then block until it returns
  //   This is busy blocking where it polls the GPU to see if it finished
  JobPointer h_JobDescription = (JobPointer) malloc(sizeof(JobDescription));
  h_JobDescription->JobType = Type;
  h_JobDescription->numThreads = Threads;
  h_JobDescription->params = d_params;
  h_JobDescription->JobID = ID;

  pthread_mutex_lock(&enqueueLock);  //Start Critical Section

  EnqueueJob(h_JobDescription, d_newJobs);

  pthread_mutex_unlock(&enqueueLock); //End Critical Section

  int first = 1;
  while(h_JobDescription->JobID!=ID || first){
    //Loop until our task is at the front of the result queue
    // Non-ideal because the task could finish but take awhile to move
    // through the queue. Cannot fix this problem with current DataStruct
    pthread_yield();
    pthread_mutex_lock(&dequeueLock);
    h_JobDescription = FrontResult(d_finishedJobs);
    if(h_JobDescription->JobID==ID)DequeueResult(d_finishedJobs);
    pthread_mutex_unlock(&dequeueLock);
    first = 0;
    printf("Current front:%d  MyID:%d\n", h_JobDescription->JobID, ID);
  }
  //printf("Recieved result on Job #%d\n", ID);
}

extern "C"
void gemtcCleanup(){
  int temp=1;
  cudaSafeMemcpy(d_kill, &temp, sizeof(int), cudaMemcpyHostToDevice, 
                 stream_dataIn, "Writing the kill command to SuperKernel");

  //Wait for SuperKernel to die
  cudaEvent_t Super_Kernel_Finished;
  cudaEventCreate(&Super_Kernel_Finished);
  cudaEventRecord(Super_Kernel_Finished, stream_kernel);
  cudaEventSynchronize(Super_Kernel_Finished);

  cudaError_t e = cudaGetLastError();

  DisposeQueue(d_newJobs);

  DisposeQueue(d_finishedJobs);

  cudaStreamDestroy(stream_kernel);
  cudaStreamDestroy(stream_dataIn);
  cudaStreamDestroy(stream_dataOut);

  pthread_mutex_destroy(&memcpyLock);
  pthread_mutex_destroy(&enqueueLock);
  pthread_mutex_destroy(&dequeueLock);
  pthread_mutex_destroy(&memoryListLock);
}

extern "C"
void gemtcPush(int taskType, int threads, int ID, void *d_parameters){
  //Enqueue the given task to the device
  //Returns as soon as the task is in Device Memory
  JobPointer h_JobDescription = (JobPointer) malloc(sizeof(JobDescription));
  h_JobDescription->JobType = taskType;
  h_JobDescription->numThreads = threads;
  h_JobDescription->params = d_parameters;
  h_JobDescription->JobID = ID;

  pthread_mutex_lock(&enqueueLock);  //Start Critical Section

  EnqueueJob(h_JobDescription, d_newJobs);

  pthread_mutex_unlock(&enqueueLock); //End Critical Section
}

extern "C"
void gemtcPoll(int *ID, void **params){
  //This function has no input parameters and two result parameters.
  //  ID and params are used as references to where the result will be written

  //This function will check the device queues for any tasks that finished
  //If none are found:
  //   Value at ID will be set to -1
  //   Value at params will be set to NULL
  //If a finished task is in the queue:
  //   Value at ID will be that task's ID
  //   Value at params will be a pointer to that tasks parameters

  JobPointer h_JobDescription = (JobPointer) malloc(sizeof(JobDescription));
  pthread_mutex_lock(&dequeueLock);  //Start Critical Section
  h_JobDescription = MaybeFandD(d_finishedJobs);//returns null if empty
  pthread_mutex_unlock(&dequeueLock); //End Critical Section
  if(h_JobDescription==NULL){
    free(h_JobDescription);
    *ID=-1;
    *params=NULL;
    return;
  }

  *ID = h_JobDescription->JobID;
  *params = h_JobDescription->params;

  free(h_JobDescription);
}

extern "C"
void gemtcMemcpyHostToDevice(void *device, void *host, int size){
  cudaSafeMemcpy(device, host, size, 
                 cudaMemcpyHostToDevice, stream_dataIn, 
                 "HostToDevice API call");
}

extern "C"
void gemtcMemcpyDeviceToHost(void *host, void *device, int size){
  cudaSafeMemcpy(host, device, size, 
                 cudaMemcpyDeviceToHost, stream_dataOut, 
                 "DeviceToHost API call");
}

extern "C"
void *gemtcGPUMalloc(int size){
  //This is defined in malloc/gemtcMalloc.cu
  return gemtcMalloc(size);
}

extern "C"
void gemtcGPUFree(void *p){
  //This is defined in malloc/gemtcMalloc.cu
  gemtcFree(p);
}
