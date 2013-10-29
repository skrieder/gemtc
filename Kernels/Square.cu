#include <stdio.h>

__device__ int Square(void *x)
{ 


  int *time = (int *) x;
  //  int *temp = (int *) malloc(sizeof(int));

  // which is equivalent to sleeping for kernel_time microseconds
  
  int i = *time;

  int j = i * i;

  *time = j;

  //x = (void *) temp;

  return 7331;
}

