#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){

  cudaDeviceProp props;
  cudaGetDeviceProperties(&props, 0);
 
  gemtcSetup(25600, 0);
  char* message = "Ben's Message"; //13 chars and a '\0'
  void* d_memory = gemtcGPUMalloc(14*sizeof(char));

  gemtcMemcpyHostToDevice(d_memory, &message, 14*sizeof(char));

  gemtcPush(15, 1, 12000, d_memory); 

  void *ret=NULL;
  int id;

  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }

  char* h_ret_message = (char *) malloc(14*sizeof(char));
  gemtcMemcpyDeviceToHost(h_ret_message, ret, 14*sizeof(char));
  printf("Received task %d\n", id);
  printf("message = %s\n", h_ret_message);

  gemtcGPUFree(ret);
  ret = NULL;

  gemtcCleanup();

  free(h_ret_message);

  return 0;
}
