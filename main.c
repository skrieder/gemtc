struct ResultPair{
  int ID;
  void *params;
};

extern void gemtcSetup(int);
extern void gemtcCleanup(void);
extern void gemtcBlockingRun(int, int, int, void*);
extern void gemtcPush(int, int, int, void*);
extern void *gemtcPoll(void);
extern void *gemtcGPUMalloc(int);
extern void gemtcGPUFree(void*);
extern void gemtcMemcpyHostToDevice(void*, void*, int);
extern void gemtcMemcpyDeviceToHost(void*, void*, int);


#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(2560);

  int i;
  for(i=0; i<1; i++){
    int sleepTime = 1000;
    int *d_sleepTime = gemtcGPUMalloc(sizeof(int));
    gemtcMemcpyHostToDevice(d_sleepTime, &sleepTime, sizeof(int));

    gemtcBlockingRun(0, 32, i, d_sleepTime);
    
    int *h_sleepTime;
    gemtcMemcpyDeviceToHost(h_sleepTime, d_sleepTime, sizeof(int));
    
    printf("!!Finished job with ID: %d   and sleepTime: %d\n", i, *h_sleepTime);
    gemtcGPUFree(d_sleepTime);
  }
  gemtcCleanup();

  return 0;
}
