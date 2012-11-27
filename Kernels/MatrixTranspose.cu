#include <stdio.h>

__device__ void MatrixTranspose(void *input)
{ 
    float* inputIn = (float*)input; 
    int N = (int)inputIn[0];
    float *matrix = inputIn+1;
    float *matrixT = matrix + N*N;
    int warp_size=32;
    int threadX = threadIdx.x % warp_size;
    for (unsigned int i = threadX; i < N; i=i+32)
    {
       //int i = threadX;
       //if (i < N)
       { 
          for (int idx = 0; idx < N; ++idx)
          {
             int idx_in = i*N+idx;
             int idx_out = idx*N+i;
             //printf("%d,%d\n",idx_in,idx_out);
             matrixT[idx_out] = matrix[idx_in]; 
             //printf("%.2f->%.2f\n", matrix[idx_in] , matrixT[idx_out]); 
          }
       }
    }
#if 0 
    if (threadX < 32 && threadY < 32)
    {
       int idx_in = threadX + 32*threadY;
       int idx_out = threadY + 32*threadX;
       matrix[idx_out] = matrix[idx_in]; 
    }
#endif
}
