#include "gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600);

  int NUM_TASKS = 20000;
  int SLEEP_TIME = 1000000;

  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    SLEEP_TIME = atoi(argv[2]);
  }
  int j;
  for(j=0; j<NUM_TASKS/10000; j++){
    int i;
    for(i=0; i<10000; i++){
      int *d_sleepTime = (int *) gemtcGPUMalloc(sizeof(int));

      gemtcMemcpyHostToDevice(d_sleepTime, &SLEEP_TIME, sizeof(int));
      gemtcPush(0, 32, i, d_sleepTime);
    }

    ResultPair *ret=NULL;
    for(i=0; i<10000; i++){
      while(ret==NULL){
        ret = (ResultPair *)gemtcPoll();
      }

      int h_sleepTime;
      gemtcMemcpyDeviceToHost(&h_sleepTime, ret->params, sizeof(int));

      gemtcGPUFree(ret->params);
      ret = NULL;
    }
    //printf("Finished group of %d,   %d\n",j, j*10000);
  }

  gemtcCleanup();

  return 0;
}
