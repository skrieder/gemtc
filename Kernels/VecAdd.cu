#include <stdio.h>
__device__ void VecAdd ( void* param1)
{
   float* mem = (float*)param1;
   int size = (int)mem[0];

   int As   = (int)mem[1];
   float *A = mem+2;

   float* C = A + As*size;

   int warp_size = 32;
   //C[tid] = A1[tid] + A2[tid] + A3[tid] + ...;

   int i;
   for(i=0; i<As; i++){
     float * cur = A + i*size;
     int tid = threadIdx.x%warp_size;
     while(tid<size){
       C[tid] += cur[tid];
       tid += warp_size;
     }
   }

   /*   while (tid < size)
   {
     int i, temp;
     temp=0;
     for(i=0; i<As; i++) temp += [tid]);
     C[tid]=temp;
     tid = tid + warp_size;
     }*/
}
