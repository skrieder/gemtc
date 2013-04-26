#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){

  int NUM_TASKS, BUNDLE_SIZE, SLEEP_TIME;

  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    BUNDLE_SIZE = atoi(argv[2]);
  }else{
    printf("This test requires two parameters:\n");
    printf("   int NUM_TASKS, BUNDLE_SIZE\n");
    printf("where  NUM_TASKS is the total numer of tasks to be run, must be a multiple of 1000\n");
    printf("       BUNDLE_SIZE is the max number of tasks to group into a single enqueue or dequeue\n");
    printf("       SLEEP_TIME is always 0.\n");
    exit(1);
  }

  SLEEP_TIME = 0;

  gemtcSetup(32768,1, BUNDLE_SIZE);

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

    for(i=0; i<1000; i++){
      void *ret=NULL;
      int id;      
      while(ret==NULL){
        gemtcPoll(&id, &ret);
      }

      int h_sleepTime;
      gemtcMemcpyDeviceToHost(&h_sleepTime, ret, sizeof(int));
      //printf("Recieved task %d\n", id);
      gemtcGPUFree(ret);
      ret = NULL;
    }
  }
  gemtcCleanup();

  return 0;
}
