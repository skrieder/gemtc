#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "gemtcCPU.h"
#include "QueueJobs.h"

int kill;

struct Parameter_t{
  Queue incoming;
  Queue results;
  int *kill;
};

#include "SuperKernel.c"

Queue newJobs, finishedJobs;

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
void CPU_gemtcSetup(int QueueSize, int numthreads){
  //initialize locks
  pthread_mutex_init(&enqueueLock, NULL);
  pthread_mutex_init(&dequeueLock, NULL);
 
  //Initialize Device Memory with Queues
  newJobs = CreateQueue(QueueSize);
  finishedJobs = CreateQueue(QueueSize);

  kill=0;


  //Launch threads

  struct Parameter_t *val = malloc(sizeof(struct Parameter_t));//This will memory leak
  val->incoming = newJobs;
  val->results = finishedJobs;
  val->kill = &kill;

  pthread_t threads[numthreads];
  int t;
  for(t=0;t<numthreads;t++){
    pthread_create(&threads[t], NULL, superKernel, (void *)val);
  }
}

void CPU_gemtcBlockingRun(int Type, int Threads, int ID, void *d_params){

  JobPointer h_JobDescription = (JobPointer) malloc(sizeof(struct JobDescription));
  h_JobDescription->JobType = Type;
  h_JobDescription->numThreads = Threads;
  h_JobDescription->params = d_params;
  h_JobDescription->JobID = ID;

  pthread_mutex_lock(&enqueueLock);  //Start Critical Section

  Enqueue(h_JobDescription, newJobs);

  pthread_mutex_unlock(&enqueueLock); //End Critical Section

  free(h_JobDescription);

  struct JobDescription ret;
  ret.JobID = -1;
  h_JobDescription = &ret;

  int first = 1;
  while(h_JobDescription->JobID!=ID || first){
    //Loop until our task is at the front of the result queue
    // Non-ideal because the task could finish but take awhile to move
    // through the queue. Cannot fix this problem with current DataStruct
    pthread_mutex_lock(&dequeueLock);
    h_JobDescription = Front(finishedJobs);
    if(h_JobDescription->JobID==ID)Dequeue(finishedJobs);
    pthread_mutex_unlock(&dequeueLock);
    first = 0;
  }
}

void CPU_gemtcCleanup(){
  kill=1;

  DisposeQueue(newJobs);

  DisposeQueue(finishedJobs);

  pthread_mutex_destroy(&enqueueLock);
  pthread_mutex_destroy(&dequeueLock);
}

void CPU_gemtcPush(int taskType, int Threads, int ID, void *parameters){

  JobPointer h_JobDescription = (JobPointer) malloc(sizeof(struct JobDescription));
  h_JobDescription->JobType = taskType;
  h_JobDescription->numThreads = Threads;
  h_JobDescription->params = parameters;
  h_JobDescription->JobID = ID;

  pthread_mutex_lock(&enqueueLock);  //Start Critical Section

  Enqueue(h_JobDescription, newJobs);

  pthread_mutex_unlock(&enqueueLock); //End Critical Section
}

void *CPU_gemtcPoll(){
  //Returns a pair with the ID and param pointer of the first job in the queue
  //If the queue is empty, this returns a NULL
  JobPointer h_JobDescription;
  pthread_mutex_lock(&dequeueLock);  //Start Critical Section
  h_JobDescription = MaybeFandD(finishedJobs);//returns null if empty
  pthread_mutex_unlock(&dequeueLock); //End Critical Section
  if(h_JobDescription==NULL){
    return NULL;
  }
  struct ResultPair *ret = (struct ResultPair *) malloc(sizeof(struct ResultPair));

  ret->ID = h_JobDescription->JobID;
  ret->params = h_JobDescription->params;

  free(h_JobDescription);
  return (void *)ret;
}
