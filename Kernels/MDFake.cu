#include<stdlib.h>
#include<stdio.h>

/* The purpose of these microkernels is to 
offer the user a sanity check. These microkernels 
take the exact same parameters as their "real" 
implementations and perform simple modifications 
so the user can be sure the kernel is unpacking 
and modifying the parameters the correct way. */ 

__device__ void FakeCompute(void* params){
 
  //Params | np | nd | mass |   pos  |   vel  |    f   |   pe   |   ke   |
  //Bytes  | 4  | 4  |  8   | 8*size | 8*size | 8*size | 8*size | 8*size | 
 
  int np = *((int*) params);
  int nd = *(((int*) params) + 1);

  int size = np * nd;

  double *mass = (double*)(((int*)params) + 2);
  double *pos = mass + 1; 
  double *vel = pos + size; 
  double *f = vel + size;

  double *pe = f + size;
  double *ke = pe + size;

  int i;
  for(i=0; i<size; i++){
    pos[i] = i;
    vel[i] = i * 2;
    f[i] = i * 3;
    pe[i] = i * 4;
    ke[i] = i * 5;
  }
}


__device__ void FakeInit(void *params){ 
  //Params| np | nd |  *acc  |  *vel  |  *pos  | *box | seed | 
  //Bytes | 4  |  4 | size*8 | size*8 | size*8 | nd*8 |   4  | 
  
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
    vel[i] = i * 2;
    pos[i] = i * 3;
  }

  box[0] = 107;
  box[1] = 107;

  *np = 1;
  *nd = 2;
  *seed = 3; 
}

__device__ void FakeUpdate(void* params){
   //Params: | np | nd |  *pos  |  *vel  |   *f   |  *acc  | mass | dt | 
  //Bytes:  | 4  | 4  | 8*size | 8*size | 8*size | 8*size |  8   |  8 | 
 
  int np = *((int*)params);
  int nd = *(((int*)params) + 1);

  int size = np * nd; 

  double *pos = ((double*)(params) + 1); 
  double *vel = pos + size;
  double *f = vel + size;
  double *acc = f + size; 

  // double mass = *(acc + size);
  //double dt = *(acc + size + 1); 

  int i; 
  for(i=0; i<size; i++){
    pos[i] = i;
    vel[i] = i*2; 
    f[i] = i*3;
    acc[i] = i*4; 
  }
}
