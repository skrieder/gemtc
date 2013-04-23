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

  payload_t* payload = currentJob->params;
  DataHeader_t* header = header_from_payload(payload);
  int payload_size = header->size;
  int sleep_length = ((sleep_task*)payload)->length;

  // Offload Region
  #pragma offload target(mic:MIC_DEV) in(payload:length(payload_size))
  {
    switch(JobType){
      case 0:
        kernel_add_sleep(payload);
        break;
    }
  }

  return currentJob;
}

