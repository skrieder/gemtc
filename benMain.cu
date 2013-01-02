#include "gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(2560);

  int i;
  for(i=0; i<10; i++){
    int sleepTime = 1000000;
    int *d_sleepTime = (int *) gemtcGPUMalloc(sizeof(int));

    gemtcMemcpyHostToDevice(d_sleepTime, &sleepTime, sizeof(int));

    //printf("Copied to device\n");

    printf("d_sleepTime is at %p\n", d_sleepTime);

    //gemtcBlockingRun(0, 32, i, d_sleepTime);
    ResultPair *ret=NULL;
    ret = (ResultPair *) gemtcPoll();
    if(ret!=NULL){
      printf("???");
      ret=NULL;
    }
    gemtcPush(0, 32, i, d_sleepTime);
    while(ret==NULL){
        ret = (ResultPair *)gemtcPoll();
    }

    int h_sleepTime;
    gemtcMemcpyDeviceToHost(&h_sleepTime, ret->params, sizeof(int));
    //gemtcMemcpyDeviceToHost(&h_sleepTime, d_sleepTime, sizeof(int));
    printf("ret->params is at %p\n", ret->params);

    printf("Finished job with ID: %d   and sleepTime: %d\n", ret->ID, h_sleepTime);
    gemtcGPUFree(d_sleepTime);
    free(ret);
    //printf("done with a loop iteration\n");
  }
  gemtcCleanup();

  return 0;
}
