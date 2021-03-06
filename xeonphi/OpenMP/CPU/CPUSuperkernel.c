#include "Queue.h"
#include <stdlib.h>
#include "Kernels/addsleep.c"
#include "Kernels/vectoradd.c"
#include "Kernels/matrix_mul.c"
#include "CPUgemtcOpenMP.h"
#include "omp.h"
#include <unistd.h>

#define SLEEP_POOL_LENGTH 0.1

JobPointer executeJob(JobPointer currentJob);

/*struct Parameter_t{
  Queue incoming;
  Queue results;
  int *kill;
};*/

extern int kill;


void *superKernel(struct Parameter_t *val)
{
   /*struct Parameter_t *params = (struct Parameter_t *) val;
   Queue incoming = params->incoming;
   Queue results =  params->results;
   int *kill =      params->kill;*/
   JobPointer currentJob;
   int i;
   //This is the function that all worker threads execute
   while(!(kill)) {

      // dequeue a task if avaliable, otherwise sleep
    //#pragma omp critical
    //{
      sleep(SLEEP_POOL_LENGTH);
      sleep(SLEEP_POOL_LENGTH);
      if ((currentJob = MaybeFandD(val->incoming)) == NULL) {
	 sleep(SLEEP_POOL_LENGTH);
	 continue;
      }
    //}
    //if (currentJob == NULL) continue;
    printf("Super exec - JobID = %d - JobType = %d - Thread = %d\n", currentJob->JobID, currentJob->JobType, omp_get_thread_num());

    //execute the task
    JobPointer retval;
    retval = executeJob(currentJob);

      //enqueue the result
    EnqueueJob(retval, val->results);     
    /*//if (!kill)
      //{
	    //dequeue a task
	 currentJob = Front(val->incoming);
	 Dequeue(val->incoming);

	    //execute the task
	 JobPointer retval;
	 retval = executeJob(currentJob);

	    //enqueue the result
	 EnqueueJob(retval, val->results);
	 printf("Resultado empilhado\n\n");
      //}*/
   }
   return;
}

JobPointer executeJob(JobPointer currentJob){

  int JobType = currentJob->JobType;

   // large switch
   switch(JobType){
      case 0:
	 addsleep(currentJob->params);
	 break;
      case 1:
	 vectoradd(currentJob->params);
	 break;
      case 2:
	 printf("Executing - %d\n", omp_get_thread_num());
	 matrix_mul(currentJob->params);
	 break;
   }
  return currentJob;
}





