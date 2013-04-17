#include "gemtc_types.h"
#include "super_kernel.h"
#include "QueueJobs.h"
#include "kernels.h"
#include <stddef.h>


void *superKernel(void *val) {

  SuperKernelParameter_t *params = (SuperKernelParameter_t *) val;
  Queue incoming = params->incoming;
  Queue results =  params->results;
  int *kill =      params->kill;

  JobDescription_t* currentJob;
  //This is the function that all worker threads execute
  while(!(*kill)) {
    //dequeue a task
    currentJob = Front(incoming);
    Dequeue(incoming);

      //execute the task
    JobDescription_t* retval;
    retval = executeJob(currentJob);

      //enqueue the result
    Enqueue(retval, results);
  }
  return NULL;
}

JobPointer executeJob(JobDescription_t* currentJob) {

  int JobType = currentJob->JobType;

  // large switch
  switch(JobType){
    case 0:
      kernel_add_sleep(currentJob->params);
      break;
  }
  return currentJob;
}

