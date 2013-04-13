#include "../../gemtc.cu"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600, 0); 

  int np = 32; 
  int nd = 2; 

  int a_size = np*nd;
  int a_mem = a_size * sizeof(double); 
   
  double mass = 1.0; 
  double dt = 0.0001; 
  double array[a_size];

  int mem_needed = sizeof(int)*2 + a_mem*4 + sizeof(double)*2; 

  void *d_mem = gemtcGPUMalloc(mem_needed);
  void *h_mem = malloc(mem_needed); 

  memcpy( h_mem                 ,   &np    , sizeof(int));
  memcpy( (((int*)h_mem)+1)     ,   &nd    , sizeof(int)); 
 
  int i;
  for(i = 0; i < 4 ; i++){
    memcpy( (((double*)h_mem) + 1 + a_size*i) , array, a_mem);
  }

  memcpy( (((double*)h_mem) + 1 + a_size*4), &mass,sizeof(double));
  memcpy( (((double*)h_mem) + 2 + a_size*4), &dt, sizeof(double)); 

  gemtcMemcpyHostToDevice(d_mem, h_mem, mem_needed);

  gemtcPush(21, 32, 12000, d_mem);

  void *ret = NULL; 
  int id;
  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }

  void* results = malloc(mem_needed);
  gemtcMemcpyDeviceToHost(results, ret, mem_needed); 
  
  double *pos = ((double*)results) + 1; 
  double *vel = pos + a_size; 
  double *f = vel + a_size;
  double *acc = f + a_size; 

  for(i = 0; i < a_size; i++){
    printf("%f %f %f %f\n", pos[i], vel[i], f[i], acc[i]);
  }

  gemtcGPUFree(results);
  ret = NULL;
  gemtcCleanup();
}
