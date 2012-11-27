#include <stdio.h>

__device__ void sleep0(void *p_kernel_time, int clockRate)
{ 
    //This method will sleep for clockRate*kernel_time many clock ticks
    // which is equivalent to sleeping for kernel_time milliseconds
    int kernel_time = *((int *) p_kernel_time);

    int finish_clock;
    int start_time;
    for(int temp=0; temp<kernel_time; temp++){
        start_time = clock();
        finish_clock = start_time + clockRate;
        bool wrapped = finish_clock < start_time;
        while( clock() < finish_clock || wrapped) wrapped = clock()>0 && wrapped;
    }
}
