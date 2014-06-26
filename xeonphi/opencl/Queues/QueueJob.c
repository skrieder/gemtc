#include <pthread.h>
#include <stdlib.h>
#include "QueueJob.h"

int IsEmpty(Queue Q) {
  return (Q->Rear+1)%Q->Capacity == Q->Front;
}

int IsFull(Queue Q) {
  return (Q->Rear+2)%Q->Capacity == Q->Front;
}

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

void Enqueue(JobPointer jobDescription, Queue Q) {

  while(IsFull(Q));//checks if the queue is full or not, 
// ; i dont get the use of this here
  // floating point exception from mod capacity if 0 or -n
int temp = (Q->Rear+1)%(Q->Capacity);//finds the next location

  // set job description
  Q->Array[temp] = *jobDescription, //stores data

  Q->Rear = temp; //marks next empty location
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


