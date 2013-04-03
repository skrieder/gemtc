#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){

  cudaDeviceProp props;
  cudaGetDeviceProperties(&props, 0);
 
  gemtcSetup(25600);
  char* message = "I am not the right message!.";
  void* d_memory = gemtcGPUMalloc(sizeof(message));

  gemtcMemcpyHostToDevice(d_memory, &message, sizeof(message));
  gemtcPush(15, 1, 12000, d_memory); 

  void *ret=NULL;
  int id;

  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }
  
  char* h_ret_message;
  gemtcMemcpyDeviceToHost(&h_ret_message, ret, sizeof(char)*20);
  printf("Received task %d\n", id);
  printf("message = %s\n", h_ret_message);

  gemtcGPUFree(ret);
  ret = NULL;

  gemtcCleanup();

  return 0;
}
