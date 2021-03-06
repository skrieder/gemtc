#include <stdio.h>
#include "Kernels/AddSleep.c"
#include "Kernels/MatrixSquare.c"
#include "Kernels/MatrixMultiply.c"

JobPointer executeJob(JobPointer currentJob);

void *superKernel(void *val)
{
  struct Parameter_t *params = (struct Parameter_t *) val;
  Queue incoming = params->incoming;
  Queue results =  params->results;
  int *kill =      params->kill;

  JobPointer currentJob;
  //This is the function that all worker threads execute
  while(!(*kill))
  {
      //dequeue a task
    currentJob = Front(incoming);
    Dequeue(incoming);

      //execute the task
    JobPointer retval;
    retval = executeJob(currentJob);

      //enqueue the result
    Enqueue(retval, results);
  }
  return NULL;
}

JobPointer executeJob(JobPointer currentJob){

  int JobType = currentJob->JobType;

  // large switch
  switch(JobType){
    case 0:
      addSleep(currentJob->params);
      break;
    case 1:
      matrixSquare(currentJob->params);
      break;
    case 2:
      matrixMultiply(currentJob->params);
      break;
  }
  return currentJob;
}

