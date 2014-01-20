#include <stdio.h>
#include "Kernels/gemtcKernelLib.cu"
#include "Kernels/AddSleep.cu"
#include "Kernels/Square.cu"
#include "Kernels/VecAdd.cu"
#include "Kernels/VecDot.cu"
#include "Kernels/VecSqrt.cu"
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
#include "Kernels/LCSubstring.cu"
#include "Kernels/MDProxy.cu"
#include "Kernels/MDFake.cu"
#include "Kernels/ArrayAtomic.cu"
#include "Kernels/ArrayRotate.cu"
#include "Kernels/SciColSim.cu"
#include "Kernels/FluidW.cu"
#include "Kernels/freezeAndPtot.cu"
#include "Kernels/FluidTVD.cu"
#include "Kernels/Pi.cu"
#include "Kernels/MatrixDet.cu"
//#include "Kernels/Sort.cu"

/*
 * Update this value whenever we add new kernel
 */
#define GEMTC_MAX_KERNELS 30

__device__ JobPointer executeJob(volatile JobPointer currentJob);

__global__ void superKernel(volatile Queue incoming, 
                            volatile Queue results, volatile int *kill)
{ 
    int warp_size = 32;

    int threadID = threadIdx.x % warp_size;
    int warpID = threadIdx.x / warp_size;   //add depenency on block?

    //Init shared memory to hold Task descriptions
    __shared__ JobPointer currentJobs[32];

    //Init general purpose shared memory
    // TODO: make this work correctly
    __shared__ char shared_mem[8192];  //8kB for the 8 warps, so 1kB each
    gemtcInitSharedMemory(shared_mem, 8192, 8);

    while(!(*kill))
    {
      //dequeue a task
      if(threadID==0)
          FrontAndDequeueJob(incoming, &currentJobs[warpID], kill);
      if(*kill)return;
      //execute the task
      volatile JobPointer retval;
      if(threadID<(currentJobs[warpID]->numThreads)) 
          retval = executeJob(currentJobs[warpID]);
      if(*kill)return;
      //enqueue the result
      if(threadID==0) EnqueueResult(retval, results, kill);
    }
    return;
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
      //      Sort(currentJob->params);
      break;
    case 4:
      VecDot(currentJob->params);
      break;
    case 5:
      MatrixMultiply(currentJob->params);
      break;
    case 6:
      MatrixTranspose(currentJob->params);
      break;
    case 7:
      MatrixVector(currentJob->params);
      break;
    case 8:
      MatrixInverse(currentJob->params);
      break;
    case 9:
      StencilCopy(currentJob->params);
    case 10:
      StencilUpdate(currentJob->params);
      break;
    case 11:
      BlackScholes(currentJob->params);
    case 12:
      ArrayMin(currentJob->params);
      break;
    case 13:
      ArrayMax(currentJob->params);
      break;
    case 14:
      ArrayAvg(currentJob->params);
      break;
    case 15:
      LCSubstring(currentJob->params);
      break;
    case 16:
      //ComputeParticles(currentJob->params);
      break;
    case 17:
      //InitParticles(currentJob->params);
      break; 
    case 18:
      //UpdatePosVelAccel(currentJob->params);
      break;
    case 19:
      ComputeTest(currentJob->params);
      break; 
    case 20:
      //Only use this kernel if you are doing multi-node.
      MDProxy(currentJob->params);
      break;
    case 21:
      VecSqrt(currentJob->params);
      break;
    case 22:
      VecSqrt(currentJob->params);
      break;
    case 23:
      Square(currentJob->params);
      break;
    case 24:
      /*
       * Imogen's ported kernel from "gpuImogen/gpuclass/cudaArrayAtomic.cu"
       */
      ArrayAtomic(currentJob->params);
      break;
    case 25:
      /*
       * Imogen's ported kernel from "gpuImogen/gpuclass/cudaArrayRotate.cu"
       */
      ArrayRotate(currentJob->params);
      break;
    case 26:
      /*
       * SciColSim's expensive function update_probabilities_all_visible() from 
       * "scicolsim-2013-03-07/src/optimizer.cpp"
       */
      gemtc_scicolsim(currentJob->params);
      break;
    case 27:
      /*
       * Imogen's ported cukern_Wstep_hydro_uniform() kernel from "gpuImogen/gpuclass/cudaFluidW.cu"
       */
      cukern_Wstep_hydro_uniform(currentJob->params);
      break;
    case 28:
      /*
       * Imogen's ported cukern_FreezeSpeed_hydro() kernel from "gpuImogen/gpuclass/freezeAndPtot.cu"
       */
      cukern_FreezeSpeed_hydro(currentJob->params);
      break;
    case 29:
      /*
       * Imogen's ported cukern_TVDStep_hydro_uniform() kernel from "gpuImogen/gpuclass/cudaFluidTVD.cu"
       */
      cukern_TVDStep_hydro_uniform(currentJob->params);
      break;
    case 30:
      /*
       * Calculates PI using Monte Carlo simulation 
       */
      gemtc_pi(currentJob->params);
      break;
    case 31:
      //Matrix Determinant ... Newly added by Karthik
      MatrixDeterminant(currentJob->params);
      break;	
  }
  return currentJob;
}

