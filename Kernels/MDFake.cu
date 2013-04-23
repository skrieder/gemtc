#include<stdlib.h>
#include<stdio.h>

/* The purpose of these microkernels is to 
offer the user a sanity check. These microkernels 
take the exact same parameters as their "real" 
implementations and perform simple modifications 
so the user can be sure the kernel is unpacking 
and modifying the parameters the correct way. */ 

__device__ void ComputeTest(void* params){
  
  //Params| &table | offset | 
  //Bytes |   8    |   4    | 
  
 void *table = *((void**)params);
 int offset = *((int*)(((void**)params)+1));
  
  //Extract all the values. 
  int np = *((int*) table);
  int nd = *(((int*) table)+1);

  int size = np * nd;

  double *mass = (double*)(((int*)table)+2);
  double *pos = mass + 1;
  double *vel = pos + size; 
  double *acc = vel + size;
  double *f = acc + size;

  double *pe = f + size;
  double *ke = pe + size;

  int j;
  int tid = threadIdx.x % 32; 
  int k = offset + tid; 
  //Compute all the potential energy and forces.     
   for(j=0; j<np; j++){
      if(k == j){ continue; }

      int index = j + k *nd;
      f[index] += 1;
      pe[index] += 1;
      ke[index] += 1;
    }
}
