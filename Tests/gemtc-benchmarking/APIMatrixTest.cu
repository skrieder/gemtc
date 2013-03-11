#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600);

  int NUM_TASKS, LOOP_SIZE, MATRIX_SIZE;

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

  int j;
  float *h_params = (float *) malloc(sizeof(float)*(1+2*MATRIX_SIZE*MATRIX_SIZE));
  h_params[0] = MATRIX_SIZE;
  for(j=1; j<MATRIX_SIZE*MATRIX_SIZE+1; j++){
    h_params[j]= ((float) rand())/INT_MAX;
  }

  for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
    int i;
    for(i=0; i<LOOP_SIZE; i++){
      float *d_params = (float *) gemtcGPUMalloc(sizeof(float)*(1+2*MATRIX_SIZE*MATRIX_SIZE));

      gemtcMemcpyHostToDevice(d_params, h_params, sizeof(float)*(1+2*MATRIX_SIZE*MATRIX_SIZE));
      gemtcPush(2, 32, i+j*LOOP_SIZE, d_params);
    }

    for(i=0; i<LOOP_SIZE; i++){
      void *ret=NULL;
      int id;
      while(ret==NULL){
        gemtcPoll(&id, &ret);
      }
      gemtcMemcpyDeviceToHost(h_params, 
                              ret, 
                              sizeof(float)*(1+2*MATRIX_SIZE*MATRIX_SIZE));

      gemtcGPUFree(ret);
      ret = NULL;
    }
  }
  gemtcCleanup();
  free(h_params);
  return 0;
}
