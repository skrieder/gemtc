#include<stdlib.h>
#include<stdio.h>

/* The purpose of these microkernels is to 
offer the user a sanity check. These microkernels 
take the exact same parameters as their "real" 
implementations and perform simple modifications 
so the user can be sure the kernel is unpacking 
and modifying the parameters the correct way. */ 

__device__ void UnpackTable(void* p){
 
  //Params | np | nd |  mass  |   pos  |   vel  |  acc   |   f    |  pe    |    ke  |
  //Bytes  | 4  | 4  |    8   | 8*size | 8*size | 8*size | 8*size | 8*size | 8*size |

  void *params = *((void**)p);

  int *np = (int*) params;
  int *nd = ((int*) params) + 1;

  int size = (*np) * (*nd);

  double *mass = ((double*)params) + 1;
  double *pos = mass + 1; 
  double *vel = pos + size; 
  double *acc = vel + size;
  double *f = acc + size;
  double *pe = f + size;
  double *ke = pe + size; 

  int i;

  *np = 107;
  *nd = 69;
  *mass = 3.1415;

  for(i=0; i<size; i++){
    pos[i] = i;
    vel[i] = i * 2;
    acc[i] = i * 3;
    f[i] = i * 4;
    pe[i] = i * 5;
    ke[i] = i * 6;
  }
}


__device__ void FakeInit(void *params){ 
  //Params| table | box[] | seed | offset |
  
  void *table = *((void**)params); 

  //Unpack Table; 
  int *np = (int*)(table);
  int *nd = np + 1;

  int size = (*np) * (*nd);

  double *pos = ((double*)(table)) + 1;
  double *vel = pos + size; 
  double *acc = vel + size; 
  
  //Unpack Params; 
  double *box = (double*)(((void**)params)+1);
  int *seed   = (int*)(box + *nd);
  int *offset = seed + 1; 

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
  *offset = 4;
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
