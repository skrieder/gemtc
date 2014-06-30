#ifndef _GEMTC_XEON_API_H
#define _GEMTC_XEON_API_H

void XEON_gemtcInitialize();
void XEON_gemtcSetup(int Queuesize, int workers);
void XEON_gemtcCleanup();
void XEON_gemtcPush(int Type, int Threads, int ID, void *params);
void XEON_gemtcPoll(int *ID, void **params);

void *XEON_gemtcMalloc(unsigned nbytes);
void XEON_gemtcFree(void *loc);


void XEON_gemtcMemcpyDeviceToHost(void *host, void *device, int size);
void XEON_gemtcMemcpyHostToDevice(void *device, void *host, int size);
