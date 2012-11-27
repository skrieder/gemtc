#include <stdio.h>

//__device__ int waitForValue(int *flag);

__device__ void clock_block(int kernel_time, int clockRate)
{ 
    int finish_clock;
    int start_time;
    for(int temp=0; temp<kernel_time; temp++){
        start_time = clock();
        finish_clock = start_time + clockRate;
        bool wrapped = finish_clock < start_time;
        while( clock() < finish_clock || wrapped) wrapped = clock()>0 && wrapped;
    }
}

__device__ int waiting(volatile int *temp){
  return *temp==0;
}

__global__ void superKernel(int *d_flagIn, int *d_flagOut)
{ 
    // init and result are arrays of integers where result should end up
    // being the result of incrementing all elements of init.
    // They have n elements and are (n+1) long. The should wait for the
    // first element to be set to zero
    int threadID = (threadIdx.x + threadIdx.y * blockDim.x);
    
    //clock_block(10,1000000);

    //int count = waitForValue(d_flagIn);

    volatile int *temp = (volatile int *)d_flagIn;
    int count=0;
    while(waiting(temp)){ 
      count++; 
    }

    if(threadID==0) *d_flagOut = count;
}

/*
__device__ int waitForValue(int *flag){
   int count = 0;
   while(true){ 
      count++;
      int *temp = (int *) malloc(sizeof(int));
      *temp = *flag;
      if (*temp!=0) {free(temp); return count;}
      free(temp);
   }
}
*/