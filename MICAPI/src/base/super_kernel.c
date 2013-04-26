#include "gemtc_types.h"
#include "gemtc_memory.h"
#include "super_kernel.h"
#include "QueueJobs.h"
#include "kernels.h"
#include <stddef.h>
#include <unistd.h>

#define SLEEP_POOL_LENGTH 0.1

void *super_kernel(void *val) {

  SuperKernelParameter_t *params = (SuperKernelParameter_t *) val;
  Queue incoming = params->incoming;
  Queue results =  params->results;
  int *kill =      params->kill;

  JobDescription_t* currentJob;
  //This is the function that all worker threads execute
  while(!(*kill)) {
    // dequeue a task if avaliable, otherwise sleep
    if ((currentJob = MaybeFandD(incoming)) == NULL) {
      sleep(SLEEP_POOL_LENGTH);
      continue;
    }

    //execute the task
    JobDescription_t* retval;
    retval = execute_job(currentJob);

      //enqueue the result
    Enqueue(retval, results);
  }
  return NULL;
}

JobPointer execute_job(JobDescription_t* currentJob) {

  int JobType = currentJob->JobType;

  DataHeader_t* header = currentJob->params;

  mic_mem_ref_t addr = header->mic_payload;

  // Offload Region
  #pragma offload target(mic:MIC_DEV) in(JobType) in(addr)
  {
    switch(JobType){
      case 0:
        kernel_add_sleep((void*)addr);
        break;
      case 16:
        MD_ComputeParticles((void*)addr);
        break;
      case 17:
        MD_InitParticles((void*)addr);
        break; 
      case 18:
        MD_UpdatePosVelAccel((void*)addr);
        break;        
    }
  }

  return currentJob;
}

