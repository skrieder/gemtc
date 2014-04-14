#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__device__ void histogram(void *input){
  uint * inputIn = (uint *) input;
  uint byteCount = inputIn[0];
  uint *d_Data = inputIn +1;
  uint *d_Histogram = d_Data + byteCount;
  int i = threadIdx.x %32;
  /*  
  if(i==0){
    printf("Thread #: %d\n",i);
    printf("Thread #: %d\n",threadIdx.x);
  }
  */	
  while (i < byteCount){
    //atomicAdd( &(d_Histogram[d_Data[i]]), 1 );
    d_Histogram[d_Data[i]]++;
    i+= 32;
  } 
}
