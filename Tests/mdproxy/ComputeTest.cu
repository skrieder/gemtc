#include "../../gemtc.cu"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600, 0);
  
  int size = sizeof(int)*2;
  
  void *d_mem = gemtcGPUMalloc(size);
  void *h_mem = malloc(size);

  int np = 5;
  int nb = 6;
  
  memcpy(h_mem, &np, sizeof(int));
  memcpy((((int*)h_mem)+1), &nb, sizeof(int));

  gemtcMemcpyHostToDevice(d_mem, h_mem, size);
  gemtcPush(16, 1, 12000, d_mem); 
 
  void *ret = NULL;
  int id;
  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }

  void* results = malloc(size);
  gemtcMemcpyDeviceToHost(results, ret, size);

  int *p_np = (int*)results;
  int *p_nb = ((int*)results)+1;
  
  printf("np is : %d\nnb is : %d\n", *p_np, *p_nb);

  gemtcGPUFree(results);
  ret = NULL;

  gemtcCleanup();
}
