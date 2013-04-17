#include <pthread.h>
#include <stdlib.h>
#include "QueueJobs.h"
#include "gemtc_types.h"

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

  Q->Array = (struct JobDescription **) malloc(sizeof(struct JobDescription)*MaxElements);

  Q->Capacity = MaxElements;
  Q->Front = 1;
  Q->Rear = 0;
  Q->ReadLock = 0;
  pthread_mutex_init(&Q->WriteLock, NULL);

  return Q;
}

void DisposeQueue(Queue Q) {
  free(Q->Array);
  pthread_mutex_destroy(&Q->WriteLock);
  free(Q);
}

////////////////////////////////////////////////////////////
// Host Functions to Change Queues
////////////////////////////////////////////////////////////

void Enqueue(JobPointer jobDescription, Queue Q) {

  while(IsFull(Q)); // I'm weary of this...

  pthread_mutex_lock(&Q->WriteLock);

    // floating point exception from mod capacity if 0 or -n
    int temp = (Q->Rear+1)%(Q->Capacity);
    
    // set job description
    Q->Array[temp] = jobDescription;

    Q->Rear = temp;

  pthread_mutex_unlock(&Q->WriteLock);
}

JobPointer MaybeFandD(Queue Q){
  if (IsEmpty(Q)){
    return NULL;
  } else {
    pthread_mutex_lock(&Q->WriteLock);
      JobPointer result = (JobPointer) malloc(sizeof(JobPointer));
      result = Q->Array[Q->Front];
      Q->Front = (Q->Front+1)%(Q->Capacity);
    pthread_mutex_unlock(&Q->WriteLock);

    return result;
  }
}