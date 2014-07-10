#include <stdlib.h>
#include "Queue.h"

////////////////////////////////////////////////////////////
// Constructor and Deconsturctor
////////////////////////////////////////////////////////////

Queue CreateQueue(int MaxElements) {
   Queue Q = (Queue) malloc (sizeof(struct QueueRecord));

   Q->Array = (struct JobDescription *) malloc(sizeof(struct JobDescription)*MaxElements);
  
   Q->Capacity = MaxElements;
   Q->Front = 1;
   Q->Rear = 0;
   Q->ReadLock = 0;
  
  return Q;
}

void DisposeQueue(Queue Q) {
  free(Q->Array);
  free(Q);
}

////////////////////////////////////////////////////////////
// Host Functions to Change Queues
////////////////////////////////////////////////////////////

void EnqueueJob(JobPointer jobDescription, Queue Q) {
//called by CPU

   if (IsFull(Q));
   
   // floating point exception from mod capacity if 0 or -n
   int temp = (Q->Rear+1)%(Q->Capacity);
    
   // set job description
   Q->Array[temp] = *jobDescription;
   Q->Rear = temp;

   return;
}

JobPointer MaybeFandD(Queue Q){

  if(IsEmpty(Q)){
    return NULL;
  }else{
    JobPointer result = (JobPointer) malloc(sizeof(JobPointer));
    *result = Q->Array[Q->Front];
    Q->Front = (Q->Front+1)%(Q->Capacity);
    return result;
  }
}

JobPointer Front(Queue Q) {
  while(IsEmpty(Q));
  JobPointer result = (JobPointer) malloc(sizeof(JobPointer));
  *result = Q->Array[Q->Front];
  return result;
}

void Dequeue(Queue Q) {
//called by CPU
  while(IsEmpty(Q));
  Q->Front = (Q->Front+1)%(Q->Capacity);
}



































