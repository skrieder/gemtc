extern void setupGemtc(int);
extern void *run(int, int, void*, int);
extern void cleanupGemtc(void);

#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>

int NUM_THREADS=4;
int JOBS_PER_THREAD=2500;
int QUEUE_SIZE=5120;
int SLEEP_TIME=0;
//int SLEEP_TIME=1000;

void *Work(void *param){
  int sleepTime = *(int *)param;

  int i;
  for(i=0; i<JOBS_PER_THREAD; i++){
    void *ret = run(0, 32, &sleepTime, sizeof(int));
    //printf("A thread finish its %dth job done\n", i);
  }
  printf("Thread done\n");
  pthread_exit(NULL);
}


int main(int argc, char **argv){

  //check for command line args
  if(argc>1){
    //    printf("The number of Jobs per thread is: %s\n", argv[1]);
    JOBS_PER_THREAD = atoi(argv[1]);
    // printf("The number of Jobs per thread is: %i\n", JOBS_PER_THREAD);
  }

  setupGemtc(QUEUE_SIZE);

  pthread_t threads[NUM_THREADS];
  pthread_attr_t attr;

  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  int i;
  for(i=0; i<NUM_THREADS; i++){
    pthread_create(&threads[i], &attr, Work, (void *)&SLEEP_TIME);
    //printf("Thread %i done.\n", i);
  }

  void * status;
  for(i=0; i<NUM_THREADS; i++){
    pthread_join(threads[i], status);
  }

  pthread_attr_destroy(&attr);
  cleanupGemtc();
  return 0;
}
