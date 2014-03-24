#include <stdio.h>

__device__
void saxpy(void *input){
  //void saxpy(int num_threads, int n, float a, float *d_x, float *d_y){

  // unbox input
  /*

  int num_threads = 32;

  int i = threadIdx.x;
  // This loop performs 3 floating point ops per iteration.
  while(i<n){
    d_y[i] = a*d_x[i] + d_y[i];
    i = i+num_threads;
  }
  */
}
