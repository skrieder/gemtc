#include"gemtc.cu"
#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>

int NUM_THREADS=1;
int JOBS_PER_THREAD=10;
int QUEUE_SIZE=1280000;
int SLEEP_TIME=0;
int MALLOC_SIZE=4;
int TASKS_PER_LOOP=1000;

void *Work(void *param){
  int j;
  for(j=0; j<JOBS_PER_THREAD/TASKS_PER_LOOP; j++){
    int i;
    int *h_sleepTime = (int *) malloc(MALLOC_SIZE);
    *h_sleepTime = SLEEP_TIME;
    for(i=0; i<TASKS_PER_LOOP; i++){
      int *d_sleepTime = (int *) gemtcGPUMalloc(MALLOC_SIZE);
      gemtcMemcpyHostToDevice((void *)d_sleepTime, (void *)h_sleepTime, MALLOC_SIZE);
      gemtcPush(0, 32, i, d_sleepTime);
    }
    ResultPair *ret=NULL;
    for(i=0; i<TASKS_PER_LOOP; i++){
      while(ret==NULL){
        ret = (ResultPair *)gemtcPoll();
      }
      gemtcMemcpyDeviceToHost(h_sleepTime, ret->params, MALLOC_SIZE);
      gemtcGPUFree(ret->params);
      ret = NULL;
    }
    free(h_sleepTime);
  }
  printf("Thread done\n");
  pthread_exit(NULL);
}


int main(int argc, char **argv){
  if(argc>4){
    NUM_THREADS = atoi(argv[1]);
    JOBS_PER_THREAD = atoi(argv[2]);
    SLEEP_TIME = atoi(argv[3]);
    MALLOC_SIZE = atoi(argv[4]);
    TASKS_PER_LOOP = atoi(argv[5]);
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
