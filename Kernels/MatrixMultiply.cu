#include <stdio.h>

__device__ void MatrixMultiply(void *input)
{ 
  int warp_size=32;
  int thread = threadIdx.x % warp_size;
  float* inputIn = (float*)input;
  int matrixWidth = inputIn[0];
  float *matrixA = inputIn+1;
    
  float *matrixB = matrixA + matrixWidth*matrixWidth;
  float *matrixOut = matrixA + 2*matrixWidth*matrixWidth;
    
  // Inlcude the oommented for printing the input and output
  /* 
    int i;
     
    // If master thread, print details
    printf("My thread id is: %d\n", thread);
    if(thread == 0){
      printf("Matrix Width is: %d\n", matrixWidth);
      printf("Printing Matrix A:\n");
      for(i=0; i<(matrixWidth*matrixWidth); i++){
      if (i%matrixWidth == 0 && i!=0)
        printf("\n");
	printf("%f ", matrixA[i]);
      }
    }

    // Print B

    if(thread == 0){
      printf("Matrix Width is: %d\n", matrixWidth);
      printf("Printing Matrix B:\n");
      for(i=0; i<(matrixWidth*matrixWidth); i++){
      if (i%matrixWidth == 0 && i!=0)
        printf("\n");
	printf("%f ", matrixB[i]);
      }
    }

    // Print C, i.e., The out Matrix
    if(thread == 0){
      printf("Matrix Width is: %d\n", matrixWidth);
      printf("Printing Matrix C:\n");
      for(i=0; i<(matrixWidth*matrixWidth); i++){
      if (i%matrixWidth == 0 && i!=0)
        printf("\n");
	printf("%f ", matrixOut[i]);
      }
    }
  */        
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
