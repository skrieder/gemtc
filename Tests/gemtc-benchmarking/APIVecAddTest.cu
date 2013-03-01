#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600);

  int NUM_TASKS, LOOP_SIZE, VECTOR_LENGTH, NUM_VECTORS;

  if(argc>3){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);
    VECTOR_LENGTH = atoi(argv[3]);
    NUM_VECTORS = atoi(argv[4]);

  }else{
    printf("This test requires four parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int VECTOR_LENGTH, int NUM_VECTORS\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    printf("       VECTOR_LENGTH is the length of each vector to be added in each task\n");
    printf("       NUM_VECTORS is the number of distinct vectors to be added together in each task\n");
    exit(1);
  }

  //EVERYTHING BELOW HERE IS COPIED STRAIGHT FROM APIMATRIXTEST.CU
  //  IT IS NOT CORRECT CODE
  //THIS IS STILL BEING WRITTEN

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

    ResultPair *ret=NULL;
    for(i=0; i<LOOP_SIZE; i++){
      while(ret==NULL){
        ret = (ResultPair *)gemtcPoll();
      }
      gemtcMemcpyDeviceToHost(h_params, 
                              ret->params, 
                              sizeof(float)*(1+2*MATRIX_SIZE*MATRIX_SIZE));

      gemtcGPUFree(ret->params);
      ret = NULL;
    }
  }
  gemtcCleanup();
  free(h_params);
  return 0;
}
