#include <stdio.h>
__device__ void VecAdd ( void* param1)
{
   int* mem = (int*)param1;
   int size = mem[0];
   int* A = mem+1;
   int* B = A+size;
   int* C = B+size;
   int warp_size = 32;
   int tid = threadIdx.x%warp_size;
   //C[tid] = A[tid] + B[tid];
#if 1 
   while (tid < size)
   {
      C[tid] = A[tid] + B[tid];
      //printf("tid:%d, C=%d\n", tid, C[tid]);
      tid = tid + warp_size;
   }
#endif

#if 0 
   int* A = (int*)param1;
   int* B = (int*)param1;
   int* C = (int*)param1;

   int tid = threadIdx.x + blockIdx.x*blockDim.x;

   while (tid < 32) {
      C[tid] = A[tid] + B[tid];
      tid += blockDim.x*gridDim.x;
   }
#endif
}
