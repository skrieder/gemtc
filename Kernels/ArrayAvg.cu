__device__ void ArrayAvg( void* param)
{
    float* paramIn = (float*)param;
    int N = (int)(*paramIn);
    paramIn = paramIn + 1;
    float* a  = paramIn;
    float* b = a + N;
    int tid = threadIdx.x;
    int cacheIndex = threadIdx.x;

    float   temp = 0;
#if 1
    while (tid < N) 
    {
        temp = temp + a[tid];
        tid += 32;
    }
#endif
    // set the cache values
    b[cacheIndex] = temp;
    //printf("Cache[%d]=%g\n", cacheIndex, temp);
#if 1
    // synchronize threads in this block
    //__syncthreads();

    // for reductions, threadsPerBlock must be a power of 2
    // because of the following code
    int i = 32/2;
    //if (cacheIndex < 0)
        //printf("i=%d,blockDim.x=%d,tid=%d\n",i, blockDim.x, cacheIndex);
    while (i != 0) 
    {
        if (cacheIndex < i )
        {
            b[cacheIndex] += b[cacheIndex+i];
        }
        i /= 2;
    }

    if (cacheIndex == 0)
    {
        //printf("c[blockIdx.x]:%g, :%d\n", cache[0],blockIdx.x);
        b[0] =  b[0]/N;
    }
#endif
}
