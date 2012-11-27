#include<cuda_runtime.h>
#include<stdio.h>

__global__ void addSleep(int *v, int *r){
  float v1 =(float) *v;
  int ret =0;
  while(ret <v1){
    ret = ret+1;
  }
  *r=ret;
}

void setupGemtc(int v){
  int * d_v, *d_r;
  cudaMalloc(&d_v, sizeof(int));
  cudaMalloc(&d_r, sizeof(int));
  cudaMemcpy(d_v, &v, sizeof(int), cudaMemcpyHostToDevice);

  dim3 threads(32, 1);
  dim3 grid(1, 1);

  addSleep<<<grid, threads, 0>>>(d_v, d_r);
  
  int r;
  cudaMemcpy(&r, d_r, sizeof(int), cudaMemcpyDeviceToHost);
  printf("%d\n", r);
}

