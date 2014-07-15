#ifndef _GEMTC_CPU_H_
#define _GEMTC_CPU_H_

#include "Queue.h"

struct Parameter_t{
  Queue incoming;
  Queue results;
  int *kill;
};

/*void CPU_gemtcSetup(int Queuesize, int numthreads);
void CPU_BlockingRun(int Type, int Threads, int ID, void *params);
void CPU_gemtcCleanup();
void CPU_gemtcPush(int Type, int Threads, int ID, void *params);
JobPointer CPU_gemtcPoll();*/

#endif