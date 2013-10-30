#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, MATRIX_SIZE;

  struct timespec start, end;
  double time_spent =0.0;

  if(argc>3){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);
    MATRIX_SIZE = atoi(argv[3]);
  }else{
    printf("This test requires three parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int MATRIX_SIZE\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    printf("       MATRIX_SIZE is the side length of the matrix that is going to be squared\n");
    exit(1);
  }

  gemtcSetup(12800, 0);

  int i, j;
  double *h_params = (double *) malloc(sizeof(double)*(3+2*MATRIX_SIZE*MATRIX_SIZE));
  memset(h_params, 0, sizeof(double)*(3+2*MATRIX_SIZE*MATRIX_SIZE));
  h_params[0] = 3;
  h_params[1] = MATRIX_SIZE;
  h_params[2] = MATRIX_SIZE;

  for(j=3; j<MATRIX_SIZE*MATRIX_SIZE+3; j++){
    h_params[j]= ((double) rand())/INT_MAX;
  }

  printf("ORIGINAL ARRAY \n");
  for(j=3; j<(MATRIX_SIZE*MATRIX_SIZE+3); j++) {
    if (((j - 3) % MATRIX_SIZE) == 0)
      printf("\n");
    printf(" %f", h_params[j]);
  }
  printf("\nBEGINING");

  clock_gettime(CLOCK_MONOTONIC_RAW, &start);
  for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
    for(i=0; i<LOOP_SIZE; i++){
      double *d_params = (double *) gemtcGPUMalloc(sizeof(double)*(3+2*MATRIX_SIZE*MATRIX_SIZE));

      gemtcMemcpyHostToDevice(d_params, h_params, sizeof(double)*(3+2*MATRIX_SIZE*MATRIX_SIZE));
      gemtcPush(25, 32, i+j*LOOP_SIZE, d_params);
    }

    for(i=0; i<LOOP_SIZE; i++){
      void *ret=NULL;
      int id;
      while(ret==NULL){
        gemtcPoll(&id, &ret);
      }
      gemtcMemcpyDeviceToHost(h_params, 
                              ret, 
                              sizeof(double)*(3+2*MATRIX_SIZE*MATRIX_SIZE));

      gemtcGPUFree(ret);
      ret = NULL;
    }
  }
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  /* Evaulate time taken for the computation */
  time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

  printf(" Time taken %f seconds\n", time_spent);
  printf("\n");
  printf("NEW ARRAY \n");
  for(j=3+MATRIX_SIZE*MATRIX_SIZE; j<2*MATRIX_SIZE*MATRIX_SIZE+3; j++) {
    if (((j - 3) % MATRIX_SIZE) == 0)
      printf("\n");
    printf(" %f", h_params[j]);
  }
  printf("\n");
  gemtcCleanup();
  free(h_params);
  return 0;
}
