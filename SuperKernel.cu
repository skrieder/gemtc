#include <stdio.h>

#include "Kernels/AddSleep.cu"
#include "Kernels/VecAdd.cu"
#include "Kernels/VecDot.cu"
#include "Kernels/MatrixSquare.cu"
#include "Kernels/MatrixMultiply.cu"
#include "Kernels/MatrixTranspose.cu"
#include "Kernels/MatrixVector.cu"
#include "Kernels/MatrixInverse.cu"
#include "Kernels/StencilCopy.cu"
#include "Kernels/StencilUpdate.cu"
#include "Kernels/BlackScholes.cu"
#include "Kernels/ArrayMin.cu"
#include "Kernels/ArrayMax.cu"
#include "Kernels/ArrayAvg.cu"


__device__ JobPointer executeJob(volatile JobPointer currentJob);

__global__ void superKernel(volatile Queue incoming, 
                            volatile Queue results, volatile int *kill)
{ 
    // init and result are arrays of integers where result should end up
    // being the result of incrementing all elements of init.
    // They have n elements and are (n+1) long. The should wait for the
    // first element to be set to zero
    int warp_size = 32;

    int threadID = threadIdx.x % warp_size;
    int warpID = threadIdx.x / warp_size;   //added depenency on block

    __shared__ JobPointer currentJobs[32];

    while(!(*kill))
    {
      //dequeue a task
      if(threadID==0)
          FrontAndDequeueJob(incoming, &currentJobs[warpID], kill);
      if(*kill)break;

      //execute the task
      volatile JobPointer retval;
      if(threadID<(currentJobs[warpID]->numThreads)) 
          retval = executeJob(currentJobs[warpID]);
      if(*kill)break;

      //enqueue the result
      if(threadID==0) EnqueueResult(retval, results, kill);
    }
}

__device__ JobPointer executeJob(JobPointer currentJob){

  int JobType = currentJob->JobType;

  // large switch
  switch(JobType){
    case 0:
      addSleep(currentJob->params);
      break;
    case 1:
      VecAdd(currentJob->params);
      break;
    case 2:
      MatrixSquare(currentJob->params);
      break;
    case 3:
      VecDot(currentJob->params);
      break;
    case 4:
      MatrixMultiply(currentJob->params);
      break;
    case 5:
      MatrixTranspose(currentJob->params);
      break;
    case 6:
      MatrixVector(currentJob->params);
      break;
    case 7:
      MatrixInverse(currentJob->params);
      break;
    case 8:
      StencilCopy(currentJob->params);
    case 9:
      StencilUpdate(currentJob->params);
      break;
    case 10:
      BlackScholes(currentJob->params);
    case 11:
      ArrayMin(currentJob->params);
      break;
    case 12:
      ArrayMax(currentJob->params);
      break;
    case 13:
      ArrayAvg(currentJob->params);
      break;
  }
  return currentJob;
}

