#include<stdlib.h>
#include<stdio.h>

__device__ void Fake_Compute(void* params){
  
  //void *table = *((void**)params);
  //int offset = *((int*)(((void **)params) + 1)); 
  
  //Extract all the values. 
  int np = *((int*) params);
  int nd = *(((int*) params) +1);

  int size = np * nd;

  double *mass = (double*)(((int*)params)+2);
  double *pos = mass + 1; 
  double *vel = pos + size; 
  double *f = vel + size;

  double *pe = f + size;
  double *ke = pe + size;

  int i;
  for(i=0; i<size; i++){
    pos[i] = i;
    vel[i] = i*2;
    f[i] = i*3;
    pe[i] = i*4;
    ke[i] = i*5;
  }
}


__device__ double r8_uniform_01(int *seed){
  
  int k = *seed/127773;
  *seed = 16807 * (*seed - k * 127773) - k * 2836; 

  if(*seed < 0 ){
    *seed += 2147483647;
  }

  double r = (double) (*seed) * 4.65661275E-10; 
  return r; 
}

__device__ void Fake_Initialize(void *params){

  //Extract all the values if they are going to be passed in. 
  int np = *((int*) params);
  int nd = *(((int*) params) +1);
  
  int size = np * nd; 
  
  int *seed = ((int*) params) +2;

  double *box = (double*)(((int*)params) +3); 
  double *pos = box + nd; 
  double *vel = pos + size;
  double *acc = vel + size; 

  int i;
  int tid = threadIdx.x % 32;

  for(i=0; i<size; i++){
    index = i + tid * nd;
      
    pos[index] = box[i] * r8_uniform_01(seed);
    vel[index] = 0.0;
    acc[index] = 0.0;
  } 
}
