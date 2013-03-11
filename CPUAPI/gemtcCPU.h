#ifndef _GEMTC_CPU_H_
#define _GEMTC_CPU_H_

pthread_mutex_t enqueueLock;
pthread_mutex_t dequeueLock;

void CPU_gemtcSetup(int Queuesize, int workers);
void CPU_BlockingRun(int Type, int Threads, int ID, void *params);
void CPU_gemtcCleanup();
void CPU_gemtcPush(int Type, int Threads, int ID, void *params);
void CPU_gemtcPoll(int *ID, void **params);
 
#endif
