#ifndef _GEMTC_MIC_API_H_
#define _GEMTC_MIC_API_H_ 1

void MIC_gemtcSetup(int Queuesize, int workers);
void MIC_gemtcCleanup();
void MIC_gemtcPush(int Type, int Threads, int ID, void *params);
void MIC_gemtcPoll(int *ID, void **params);

void *MIC_gemtcMalloc(unsigned nbytes);
void MIC_gemtcFree(void *loc);

//void MIC_gemtcMemcpyHostToDevice(void *device, void *host, int size);
//void MIC_gemtcMemcpyDeviceToHost(void *host, void *device, int size);

/*
*** Memory Transfer Calls  ***
  gemtcMemcpyHostToDevice()
  gemtcMemcpyDeviceToHost()

****Memory Management Calls***
  gemtcGPUMalloc()
  gemtcGPUFree()
*/
#endif
