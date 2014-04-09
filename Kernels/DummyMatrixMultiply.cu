// Not a real AppKernel
// Dummy Kernel for HPDC Paper

__device__ void MatrixMultiply(void *input)
{ 
  // calibrate for warp size
  int warp_size = 32;
  int thread = threadIdx.x % warp_size;
  
  // unbox the host parameters
  float* inputParams = (float*)input;
  int matrixWidth = inputParams[0];
  float *matrixA = inputParams+1;
  float *matrixB = matrixA + matrixWidth*matrixWidth;
  float *matrixOut = matrixA + 2*matrixWidth*matrixWidth;
  
  for (unsigned int i = thread; i < matrixWidth; i=i+32){
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

