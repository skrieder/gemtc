#include"../../gemtc.cu"
#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>

int NUM_THREADS;
int JOBS_PER_THREAD;
int QUEUE_SIZE=12800;
int SLEEP_TIME;
int MALLOC_SIZE;
int LOOP_SIZE;

void *Work(void *param){
  // loop over the jobs per thread mod 10k
  int j;
  for(j=0; j<JOBS_PER_THREAD/LOOP_SIZE; j++){
    int i;
    int *h_sleepTime = (int *) malloc(MALLOC_SIZE);
    *h_sleepTime = SLEEP_TIME;
    for(i=0; i<LOOP_SIZE; i++){
      int *d_sleepTime = (int *) gemtcGPUMalloc(MALLOC_SIZE);
      gemtcMemcpyHostToDevice((void *)d_sleepTime, (void *)h_sleepTime, MALLOC_SIZE);
      gemtcPush(0, 32, i, d_sleepTime);
    }
    for(i=0; i<LOOP_SIZE; i++){
      void *ret=NULL;
      int id;
      while(ret==NULL){
        gemtcPoll(&id, &ret);
      }
      gemtcMemcpyDeviceToHost(h_sleepTime, ret, MALLOC_SIZE);
      gemtcGPUFree(ret);
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
    LOOP_SIZE = atoi(argv[5]);
  }else{
    printf("This test requires five parameters:\n");
    printf("   int NUM_THREADS, int JOBS_PER_THREAD, int SLEEP_TIME, int MALLOC_SIZE, int LOOP_SIZE\n");
    printf("where  NUM_THREADS is the number of seperate threads that will be sending work into gemtc\n");
    printf("       JOBS_PER_THREAD is the number of tasks that a given thread will submit to gemtc\n");
    printf("       SLEEP_TIME is the parameter that will be given to each AddSleep micro-kernel, in microseconds\n");
    printf("       MALLOC_SIZE is the amount of memory that will be allocated and transfered with each sleep\n");
    printf("                   This number must be a multiple of 4, to comply with cuda's memory requirements\n");
    printf("       LOOP_SIZE is the number of tasks a thread will submit to gemtc before waiting for results\n");
    exit(1);
  }

  // call gemtcSetup with the queue size
  gemtcSetup(QUEUE_SIZE, 1);

  // set the number of threads
  pthread_t threads[NUM_THREADS];
  pthread_attr_t attr;

  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  // loop over the number of threads and create them
  int i;
  for(i=0; i<NUM_THREADS; i++){
    int *id = (int *)malloc(sizeof(int));
    *id=i;
    pthread_create(&threads[i], &attr, Work, (void *) id);
  }

  // wait for the threads to join
  void *status;
  for(i=0; i<NUM_THREADS; i++){
    pthread_join(threads[i], &status);
  }

  // cleanup threads and gemtc
  pthread_attr_destroy(&attr);
  gemtcCleanup();
  return 0;
}
