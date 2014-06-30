#ifndef _GEMTC_TYPES_H_
#define _GEMTC_TYPES_H_

#include "gemtc_memory.h"

struct JobDescription{
  int JobID;
  int JobType;
  int numThreads;
  mic_mem_ref_t params;
};

typedef struct JobDescription JobDescription_t;
typedef struct JobDescription *JobPointer;

#ifndef MIC_DEV
#define MIC_DEV 0
#endif

#endif
