#include "../../gemtc.cu"
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv){
  gemtcSetup(25600, 0);
  
  int np = 5;
  int nd = 2; 
  int seed = 123456789;
  
  int a_size = np * nd;
  int a_mem = sizeof(double) * a_size;

  double darray[a_size];

  int mem_needed = sizeof(int)*4 + a_mem; 
  
  void *d_mem = gemtcGPUMalloc(mem_needed);
  void *h_mem = malloc(mem_needed);

//  Memory is lines up like this:
//Content:   np  |  nd  | seed | blank | darray
//Bytes:     4      4     4      4       80

  memcpy( h_mem               , &np   , sizeof(int));
  memcpy( (((int*)h_mem)+1)   , &nd   , sizeof(int));
  memcpy( (((int*)h_mem)+2)   , &seed , sizeof(int)); 
  memcpy( (((int*)h_mem)+4)   , darray, a_mem); 

  gemtcMemcpyHostToDevice(d_mem, h_mem, mem_needed);
  gemtcPush(17, 1, 11000, d_mem);

  void *ret = NULL;
  int id;
  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }

  printf("Got the results!\n");
  void* results = malloc(mem_needed);
  gemtcMemcpyDeviceToHost(results, ret, mem_needed);

  int *pnp = (int*)results;
  int *pnd = pnp + 1;
  int *pseed = pnd + 1;
  double *boxes = (double*)(pseed + 2);
  printf("The first three values are: %d %d %d\n", *pnp, *pnd, *pseed);

  int i;
  for(i=0; i<a_size; i++){
    printf("%f\n", boxes[i]);
  }

  gemtcGPUFree(results);
  ret = NULL;

  gemtcCleanup();
}
