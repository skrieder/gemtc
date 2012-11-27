#include <stdio.h>

__device__ void MatrixMultiply(void *input)
{ 
    float* inputIn = (float*)input;
    int matrixWidth = inputIn[0];
    float *matrixA = inputIn+1;
    float *matrixB = matrixA + matrixWidth*matrixWidth;
    float *matrixOut = matrixA + 2*matrixWidth*matrixWidth;
    int warp_size=32;
    int thread = threadIdx.x % warp_size;
        
    for (unsigned int i = thread; i < matrixWidth; i=i+32)
    {
      for (unsigned int j = 0; j < matrixWidth; j++) {
         float sum = 0;
         for (unsigned int k = 0; k < matrixWidth; k++) {
           float a = matrixA[i * matrixWidth + k];
           float b = matrixB[k * matrixWidth + j];
           sum += a * b;
         }
         matrixOut[i * matrixWidth + j ] = sum;
      }
   }
}
