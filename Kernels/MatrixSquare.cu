#include <stdio.h>

__device__ void MatrixSquare(void *param)
{ 
    float *input = (float *) param;
    int warp_size=32;
    int matrixWidth = (int)input[0];
    float* matrix = input+1;
    float* matrixOut = matrix + matrixWidth*matrixWidth;
    //printf("%d\n", matrixWidth);
#if 1 
    int thread = threadIdx.x % warp_size;
        
    for (unsigned int i = thread; i < matrixWidth; i=i+32)
    {
      for (unsigned int j = 0; j < matrixWidth; j++) {
         float sum = 0;
         for (unsigned int k = 0; k < matrixWidth; k++) {
           float a = matrix[i * matrixWidth + k];
           float b = matrix[k * matrixWidth + j];
           sum += a * b;
         }
         //matrixOut[i * matrixWidth + j + (matrixWidth * matrixWidth)] = sum;
         matrixOut[i * matrixWidth + j ] = sum;
      }
   }
#endif
}
