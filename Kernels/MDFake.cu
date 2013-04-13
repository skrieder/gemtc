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


__device__ void FakeInit(void *params){ 
  
  int *np = (int*)(params);
  int *nd = np + 1;

  int size = (*np) * (*nd);

  double *acc = ((double*)(params)) + 1;
  double *vel = acc + size; 
  double *pos = vel + size;
  double *box = pos + size; 

  int *seed = (int*)(box + *nd); //box size is ND.  
  
  int i;
  for(i=0; i<size; i++){
    acc[i] = i;
    vel[i] = i*2;
    pos[i] = i*3;
  }

  box[0] = 107;
  box[1] = 107;

  *np = 1;
  *nd = 2;
  *seed = 3; 
}
