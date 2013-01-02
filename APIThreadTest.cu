#include"gemtc.cu"
#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>

int NUM_THREADS=1;
int JOBS_PER_THREAD=10;
int QUEUE_SIZE=1280000;
int SLEEP_TIME=0;

void *Work(void *param){
  int j;
  for(j=0; j<JOBS_PER_THREAD/10000; j++){
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
  printf("Thread done\n");
  pthread_exit(NULL);
}


int main(int argc, char **argv){
  if(argc>3){
    NUM_THREADS = atoi(argv[1]);
    JOBS_PER_THREAD = atoi(argv[2]);
    SLEEP_TIME = atoi(argv[3]);
  }

  gemtcSetup(QUEUE_SIZE);

  pthread_t threads[NUM_THREADS];
  pthread_attr_t attr;

  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  int i;
  for(i=0; i<NUM_THREADS; i++){
    int *id = (int *)malloc(sizeof(int));
    *id=i;
    pthread_create(&threads[i], &attr, Work, (void *) id);
  }

  void *status;
  for(i=0; i<NUM_THREADS; i++){
    pthread_join(threads[i], &status);
  }

  pthread_attr_destroy(&attr);
  gemtcCleanup();
  return 0;
}
