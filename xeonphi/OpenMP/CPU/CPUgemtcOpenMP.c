#include <stdio.h>
#include <stdlib.h>
//#include "CPUgemtcOpenMP.h"
#include "Queue.h"
#include "CPUSuperkernel.c"
#include "omp.h"

/*struct Parameter_t{
  Queue incoming;
  Queue results;
  int *kill;
};*/

//void CPU_gemtcSetup(int Queuesize, int numthreads);
struct Parameter_t * CPU_gemtcSetup(int Queuesize, int numthreads);
void CPU_BlockingRun(int Type, int Threads, int ID, void *params);
void CPU_gemtcCleanup();
void CPU_gemtcPush(int Type, int Threads, int ID, void *params);
JobPointer CPU_gemtcPoll();

Queue newJobs, finishedJobs;
extern int kill;

/*
This file contains the functions that make up the API to gemtc
They are:
*** Initialize/Deconstruct ***
  CPU_gemtcSetup()
  CPU_gemtcCleanup()

*** EnQueue/DeQueue Tasks  ***
  CPU_gemtcBlockingRun()
  CPU_gemtcPush()
  CPU_gemtcPoll()
 */

/////////////////
//API Functions//
/////////////////

//void CPU_gemtcSetup(int QueueSize, int numthreads){
struct Parameter_t * CPU_gemtcSetup(int QueueSize, int numthreads){
 
   //Initialize Device Memory with Queues
   newJobs = CreateQueue(QueueSize);
   finishedJobs = CreateQueue(QueueSize);

   kill=0;

   //Launch threads

   struct Parameter_t *val = malloc(sizeof(struct Parameter_t));//This will memory leak
   val->incoming = newJobs;
   val->results = finishedJobs;
   val->kill = &kill;
   
   //omp_set_num_threads(numthreads);
   
   //#pragma omp single nowait
   //{
      //superKernel(val);
   //}
   return val;
}

void CPU_gemtcCleanup(){
  kill=1;

  DisposeQueue(newJobs);

  DisposeQueue(finishedJobs);

  //pthread_mutex_destroy(&enqueueLock);
  //pthread_mutex_destroy(&dequeueLock);
  return;
}

void CPU_gemtcPush(int taskType, int Threads, int ID, void *parameters){

   //Start Critical Section
   #pragma omp critical
   {
      JobPointer h_JobDescription = (JobPointer) malloc(sizeof(struct JobDescription));
      h_JobDescription->JobType = taskType;
      h_JobDescription->numThreads = Threads;
      h_JobDescription->params = parameters;
      h_JobDescription->JobID = ID;

      EnqueueJob(h_JobDescription, newJobs);
      printf ("TAREFA EMPILHADA\n\n");
   }
   //End Critical Section
  
  return;
}

JobPointer CPU_gemtcPoll(){
   //ID and params a references to where the output should be written
   //This function has no real parameters
   //ID is -1 and params is NULL if no tasks have finished

   JobPointer h_JobDescription;
  
   //Start Critical Section
   #pragma omp critical
   {
      printf("ENTROU NA CRITICAL DO POLL\n");
      h_JobDescription = MaybeFandD(finishedJobs);//returns null if empty
   //End Critical Section
   }
   if(h_JobDescription==NULL){
      //*ID=-1;
      //*params=NULL;
      return NULL;
   }

   //*ID = h_JobDescription->JobID;
   //*params = h_JobDescription->params;

   //free(h_JobDescription);
   return h_JobDescription;
}



























