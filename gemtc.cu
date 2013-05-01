#include <stdio.h>
#include <cuda_runtime.h>
#include <pthread.h>
#include <sys/time.h>
#include <unistd.h>
struct timeval tp;

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

//Jobs going in to the GPU
JobDescription *inBuffer;
int inSize;
int inMax;
double timeStamp;
//Jobs coming out of the GPU
JobDescription *outBuffer;
int outSize;
int outMax;

/*
This file contains the functions that make up the API to gemtc
They are:
*** Initialize/Deconstruct ***
  gemtcSetup()
  gemtcCleanup()

*** EnQueue/DeQueue Tasks  ***
  -- gemtcBlockingRun()   Not up to date
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
double getTime_usec() {
    gettimeofday(&tp, NULL);
    return static_cast<double>(tp.tv_sec) * 1E6
            + static_cast<double>(tp.tv_usec);
}
void *bufferFlush(void *junk){
  while(1){
    pthread_mutex_lock(&enqueueLock);  //Start Critical Section

    double curTime = getTime_usec();
    if(curTime-timeStamp > 100 && inSize!=0){
      EnqueueJobBatch(inBuffer, inSize, d_newJobs);
      inSize=0;
    }

    pthread_mutex_unlock(&enqueueLock); //End Critical Section
    pthread_yield();  //wait for awhile before polling again
  }
}

/////////////////
//API Functions//
/////////////////
extern "C"
void gemtcSetup(int QueueSize, int Overfill){
//QueueSize determines the size of both of the queues in GPU memory
//  that hold pointers to task descriptions for new and finished tasks
//Overfill is a flag:
//  0  means  launch enough warps to have a one-to-one mapping with 
//            16 Cuda Core Groupings. High Efficiency
//  1  means  launch the maximum number of warps per SM
//            Highest Throughput
//            Extra warps will be "Hyperthreaded"

  //initialize locks
  pthread_mutex_init(&memcpyLock, NULL);
  pthread_mutex_init(&enqueueLock, NULL);
  pthread_mutex_init(&dequeueLock, NULL);
  pthread_mutex_init(&memoryListLock, NULL);

  inMax = 100;
  inSize = 0;
  inBuffer = (JobDescription *) malloc(inMax*sizeof(JobDescription));
  timeStamp = 0;

  outMax = 100;
  outSize = 0;
  outBuffer = (JobDescription *) malloc(outMax*sizeof(JobDescription));

  cudaDeviceProp devProp;
  cudaGetDeviceProperties(&devProp, 0); //default to first GPU

  int warp_size = devProp.warpSize;  //Always 32
  int warps;
  int blocks = devProp.multiProcessorCount;
  if(Overfill){
    warps = devProp.maxThreadsPerBlock/32;
  }else{
    int coresPerSM = _ConvertSMVer2Cores(devProp.major, devProp.minor);
    warps = coresPerSM/16;  //A warp runs on 16 cores
  }

  printf("Workers:  %d\n", warps*blocks);

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

  //Launch thread to dump outBuffer
  pthread_t bufferFlusher;
  pthread_create(&bufferFlusher, NULL, bufferFlush, NULL);

//Launch the super kernel
  superKernel<<< grid, threads, 8192, stream_kernel>>>  //8192 = 8kBytes of shared Memory
             (d_newJobs, d_finishedJobs, d_kill);
}


//This function is currently out of date
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
  pthread_mutex_lock(&enqueueLock);  //Start Critical Section

  inBuffer[inSize].JobType = taskType;
  inBuffer[inSize].numThreads = threads;
  inBuffer[inSize].params = d_parameters;
  inBuffer[inSize].JobID = ID;
  inSize++;

  timeStamp = getTime_usec();

  if(inSize==inMax){
    EnqueueJobBatch(inBuffer, inSize, d_newJobs);
    inSize=0;
  }
  pthread_mutex_unlock(&enqueueLock); //End Critical Section
}

extern "C"
void gemtcPoll(int *ID, void **params){
  pthread_mutex_lock(&dequeueLock);  //Start Critical Section

  if(outSize==0){
    outSize = FrontAndDequeueBatch(outBuffer, outMax, d_finishedJobs);//returns null if empty
  }
  if(outSize==0){
    *ID=-1;
    *params=NULL;
    pthread_mutex_unlock(&dequeueLock); //End Critical Section
    return;
  }else{
    outSize--;
    *ID = outBuffer[outSize].JobID;
    *params = outBuffer[outSize].params;
  }
  pthread_mutex_unlock(&dequeueLock); //End Critical Section
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
