#include <stdio.h>

__device__ void MatrixSquare(void *input)
{ 
    float *matrix = (float *) input;
    int warp_size=32;
    int thread = threadIdx.x % warp_size;
        
    int matrixWidth = 32;
    for (unsigned int i = thread; i < matrixWidth; i=i+32)
    {
      for (unsigned int j = 0; j < matrixWidth; j++) {
         float sum = 0;
         for (unsigned int k = 0; k < matrixWidth; k++) {
           float a = matrix[i * matrixWidth + k];
           float b = matrix[k * matrixWidth + j];
           sum += a * b;
         }
         matrix[i * matrixWidth + j + (matrixWidth * matrixWidth)] = sum;
      }
   }
}
