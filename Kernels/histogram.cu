#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__device__ void histogram(
        void *input
)
{
        uint * inputIn = (uint *) input;
        uint byteCount = inputIn[0];

        uint *d_Data = inputIn +1;
        uint *d_Histogram = d_Data + byteCount;


		int i = threadIdx.x %32;
		
	
		while (i < byteCount)
		{
				atomicAdd( &(d_Histogram[d_Data[i]]), 1 );
				i+= 32;
		}

}
