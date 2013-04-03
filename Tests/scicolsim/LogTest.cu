#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){

  cudaDeviceProp props;
  cudaGetDeviceProperties(&props, 0);
  
  //We have 1024 MB 
  //printf("\tGlobal memory: %d mb\n", (int) (props.totalGlobalMem/(1024*1024)));

  gemtcSetup(25600);
  int NUM_NODES = 0;
  int *d_num_nodes = (int *)gemtcGPUMalloc(sizeof(int));

  gemtcMemcpyHostToDevice(d_num_nodes, &NUM_NODES, sizeof(int));
  gemtcPush(15, 1, 12000, d_num_nodes); 

  void *ret=NULL;
  int id;

  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }
  
  int h_num_nodes;
  gemtcMemcpyDeviceToHost(&h_num_nodes, ret, sizeof(int));
  printf("Received task %d\n", id);
  printf("ret_val = %d\n", h_num_nodes);

  gemtcGPUFree(ret);
  ret = NULL;

  gemtcCleanup();

  return 0;
}
