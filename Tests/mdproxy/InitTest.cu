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
  double box[nd];

  int mem_needed = sizeof(int)*3 + a_mem*3 + nd*sizeof(double); 
  
  void *d_mem = gemtcGPUMalloc(mem_needed);
  void *h_mem = malloc(mem_needed);

  memcpy( h_mem               , &np   , sizeof(int));
  memcpy( (((int*)h_mem)+1)   , &nd   , sizeof(int)); 
  memcpy( (((int*)h_mem)+2)   , darray, a_mem); 

  int i;
  for(i=0; i<3; i++){
    memcpy( ((double*)(h_mem)) + 1 + a_size*i , darray, a_mem);
  }

  memcpy( ((double*)(h_mem)) + 1 + a_size*3, box, sizeof(double)*nd); 
  memcpy( (((double*)(h_mem)) + 1 + a_size*3 + nd), &seed, sizeof(int));

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
  
  double *acc = (double*)results + 1; 
  double *vel = acc + a_size; 
  double *pos = vel + a_size;
  double *pbox = pos + a_size; 

  int *pseed = (int*)(pbox + nd); 

  printf("np = %d\n nd = %d\n seed = %d\n", *pnp, *pnd, *pseed);

  for(i=0; i<a_size; i++){
    printf("%f %f %f\n", acc[i], vel[i], pos[i]);
  }

  gemtcGPUFree(results);
  ret = NULL;

  gemtcCleanup();
}
