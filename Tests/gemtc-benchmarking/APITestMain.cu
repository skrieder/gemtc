#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){

  cudaDeviceProp props;
  cudaGetDeviceProperties(&props, 0);
  printf("  Global memory:  %d mb\n", (int) props.totalGlobalMem);
  printf("  Shared memory:  %d kb/block\n ",(int) props.sharedMemPerBlock);

  gemtcSetup(25600);

  int NUM_TASKS = 20000; //Must be a multiple of 1000
  int SLEEP_TIME = 1000000;

  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    SLEEP_TIME = atoi(argv[2]);
  }

  //We will Push 1000 tasks
  // Then Poll until we have 1000 results
  // Untilwe have run all the tasks
  int j;
  for(j=0; j<NUM_TASKS/1000; j++){
    int i;
    for(i=0; i<1000; i++){
      int *d_sleepTime = (int *) gemtcGPUMalloc(sizeof(int));

      gemtcMemcpyHostToDevice(d_sleepTime, &SLEEP_TIME, sizeof(int));
      gemtcPush(0, 32, i+j*1000, d_sleepTime);
    }

    ResultPair *ret=NULL;
    for(i=0; i<1000; i++){
      while(ret==NULL){
        ret = (ResultPair *)gemtcPoll();
      }

      int h_sleepTime;
      gemtcMemcpyDeviceToHost(&h_sleepTime, ret->params, sizeof(int));
      printf("Recieved task %d\n", ret->ID);
      gemtcGPUFree(ret->params);
      ret = NULL;
    }
  }

  gemtcCleanup();

  return 0;
}
