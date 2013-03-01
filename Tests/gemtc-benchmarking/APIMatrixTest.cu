#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600);

  int NUM_TASKS = 100;
  int MATRIX_SIZE = 32;
  int LOOP_SIZE = 100;

  if(argc>3){
    NUM_TASKS = atoi(argv[1]);
    MATRIX_SIZE = atoi(argv[2]);
    LOOP_SIZE = atoi(argv[3]);
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
