#ifndef _GEMTC_TYPES_H_
#define _GEMTC_TYPES_H_

struct JobDescription{
  int JobID;
  int JobType;
  int numThreads;
  void *params;
};

typedef struct JobDescription JobDescription_t;
typedef struct JobDescription *JobPointer;

#endif