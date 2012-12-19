#include <stdio.h>

__device__ int addSleep(void *p_us_time)
{ 
    //This method will sleep for clockRate*kernel_time many clock ticks
    // which is equivalent to sleeping for kernel_time microseconds
    int *time = (int *) p_us_time;


    float AddPerUs = 17.69911504424; //Ben
    //float AddPerUs = 9.89759943623274; //Scott Mainh.cu
    //float AddPerUs = 18.3952025; //Scott Main.c
    //float AddPerUs = 1; // Test

    int adds = (*time)*AddPerUs;

    int save_time = *time;

    //    int temp=0;
    //while(temp<adds){
      //   temp++;
       //}
    while(adds>0){
       adds--;
       (*time)--;
    }

    *time = save_time;

    return *time;
}
