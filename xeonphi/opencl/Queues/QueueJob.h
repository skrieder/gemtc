#ifndef _XEON_QUEUEJOBS_H_
#define _XEON_QUEUEJOBS_H_


struct JobDescription{
  int JobID;
  int JobType;
  int numThreads;
  void *params;
};
typedef struct JobDescription *JobPointer;

struct QueueRecord {
  struct JobDescription* Array;
  int Capacity;
  int Rear;
  int Front;
  int ReadLock;
};
typedef struct QueueRecord *Queue;

Queue CreateQueue(int size);
void DisposeQueue(Queue Q);
void Enqueue(JobPointer job, Queue Q);
JobPointer MaybeFandD(Queue Q);
JobPointer Front(Queue Q);
void Dequeue(Queue Q);

#endif


