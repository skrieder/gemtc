#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, ARRAY_SIZE;

  struct timespec start, end;
  double time_spent =0.0;
  if(argc>3){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);
    ARRAY_SIZE = atoi(argv[3]);
  }else{
    printf("This test requires three parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int ARRAY_SIZE\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    printf("       ARRAY_SIZE is the side length of the matrix that is going to be squared\n");
    exit(1);
  }

  gemtcSetup(12800, 0);

  int j;
  double *h_params = (double *) malloc(sizeof(double)*(3+ARRAY_SIZE));
  h_params[0] = 1;

  /*
   * Minimum threshold
   */
  h_params[1] = 0.053;
  h_params[2] = ARRAY_SIZE;
  for(j=3; j<ARRAY_SIZE+3; j++){
    h_params[j]= ((double) rand())/INT_MAX;
  }

  /*
   * Purposefully set 1 array parameters to be lessa then minimum
   */
  h_params[5] = .009;
  printf("Minimum Threshold %f\n", h_params[1]);
  printf("ORIGINAL ARRAY \n");
  for(j=3; j<ARRAY_SIZE+3; j++) {
    printf("Element %f\n", h_params[j]);
  }
  printf("\n");
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
    int i;
    for(i=0; i<LOOP_SIZE; i++){
      double *d_params = (double *) gemtcGPUMalloc(sizeof(double)*(3+ARRAY_SIZE));

      gemtcMemcpyHostToDevice(d_params, h_params, sizeof(double)*(3+ARRAY_SIZE));
      gemtcPush(24, 32, i+j*LOOP_SIZE, d_params);
    }

    for(i=0; i<LOOP_SIZE; i++){
      void *ret=NULL;
      int id;
      while(ret==NULL){
        gemtcPoll(&id, &ret);
      }
      gemtcMemcpyDeviceToHost(h_params, 
                              ret, 
                              sizeof(double)*(3+ARRAY_SIZE));
      gemtcGPUFree(ret);
      ret = NULL;
    }
  }
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  /* Evaulate time taken for the computation */
  time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

  printf(" Time taken %f seconds\n", time_spent);
  printf("\n");
  printf("NORMALIZED ARRAY \n");
  for(j=3; j<ARRAY_SIZE+3; j++) {
    printf("Element %f\n", h_params[j]);
  }
  printf("\n");
  gemtcCleanup();
  free(h_params);
  return 0;
}
