#include <stdio.h>
__device__ void VecAdd ( void* param1)
{
   float* mem = (float*)param1;
   int size = (int)mem[0];

   int As   = (int)mem[1];
   float *A = mem+2;

   float* C = A + As*size;

   int warp_size = 32;
   int tid = threadIdx.x%warp_size;
   //C[tid] = A[tid] + B[tid];
   while (tid < size)
   {
     int i, temp=0;
     for(i=0;i<As;i++)temp += A[tid+i*size];
     C[tid]=temp;
     tid = tid + warp_size;
   }
}
