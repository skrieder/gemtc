#include <stdlib.h>
#include "Queue.h"
#include <stdio.h>
#include "omp.h"

extern omp_lock_t writelock;

////////////////////////////////////////////////////////////
// Constructor and Deconstructor
////////////////////////////////////////////////////////////

Queue CreateQueue(int MaxElements) {
   Queue Q = (Queue) malloc (sizeof(struct QueueRecord));
   int i;

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
   int temp;
   //omp_lock_t writelock;

  // omp_init_lock(&writelock);
  
   while (IsFull(Q));

  // while(!omp_test_lock(&writelock));
   omp_set_lock(&writelock);

   //#pragma omp critical
   //{ 
      // floating point exception from mod capacity if 0 or -n
      temp = (Q->Rear+1)%(Q->Capacity);
      //printf ("Rear = %d\n", temp);
      // set job description
      Q->Array[temp] = *jobDescription;
      Q->Rear = temp;
  // }
   omp_unset_lock(&writelock);
   #pragma omp flush
   return;
}

JobPointer MaybeFandD(Queue Q){

   //omp_lock_t writelock;
   
   JobPointer result = (JobPointer) malloc(sizeof(JobPointer));

  // omp_init_lock(&writelock);
  //while(!omp_test_lock(&writelock));
   
   if(IsEmpty(Q)){
      free(result);
      omp_unset_lock(&writelock);
      return NULL;
   }else{
	// #pragma omp critical
	// {
	 omp_set_lock(&writelock);
	 if (IsEmpty(Q)) {
	    omp_unset_lock(&writelock);
	    return NULL;
	 }
	 //JobPointer result = (JobPointer) malloc(sizeof(JobPointer));
	 *result = Q->Array[Q->Front];
	// printf("Front = %d\n", Q->Front);
	 Q->Front = (Q->Front+1)%(Q->Capacity);
	 omp_unset_lock(&writelock);
      //}
   }
	 #pragma omp flush
	 return result;
      //}
      
}

JobPointer Front(Queue Q) {
  while(IsEmpty(Q));
   /*if (IsEmpty(Q)) {
      printf ("Front error!!!\n");
      exit(1);
   }*/
  JobPointer result = (JobPointer) malloc(sizeof(JobPointer));
  *result = Q->Array[Q->Front];
  return result;
}

void Dequeue(Queue Q) {
//called by CPU
  while(IsEmpty(Q));
   /*if (IsEmpty(Q)) {
      printf ("Dequeue error!!!\n");
      exit(1);
   }*/
  Q->Front = (Q->Front+1)%(Q->Capacity);
   return;
}


int IsEmpty(Queue Q) {
  return (Q->Rear+1)%Q->Capacity == Q->Front;
}

int IsFull(Queue Q) {
  return (Q->Rear+2)%Q->Capacity == Q->Front;
}








