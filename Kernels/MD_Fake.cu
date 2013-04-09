#include<stdlib.h>
#include<stdio.h>

__device__ void FakeCompute(void* params){
  
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

__device__ void FakeInit(void *params){

  //Extract all the values if they are going to be passed in. 
  int *np = (int*)params;
  int *nd = np + 1;
  int *seed = nd + 1;

  *np = 1;
  *nd = 2;
  *seed = 3; 
}
