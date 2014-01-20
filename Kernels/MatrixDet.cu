#include <stdio.h>


__device__ void MatrixDeterminant(void *param)
{ 
    float *input = (float *) param;
    int warp_size=32;
    int n = (int)input[0];
    float* matrix = input+1;
    int thread = threadIdx.x % warp_size;
    float value;
    float *det = input + n*n;    
    if(n < 1){
    //Error return 0
    value = 0; 
    }
    else {
    if(n==1) 
     value = matrix[0];
    else if(n==2) 
     value =  matrix[0] * matrix[3] - matrix[2] * matrix[1];
     

    }
    *det = value;
    
}

