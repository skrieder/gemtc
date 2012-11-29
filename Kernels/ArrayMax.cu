__device__ void ArrayMax( void* param)
{
    float* paramIn = (float*)param;
    int N = (int)(*paramIn);
    paramIn = paramIn + 1;
    float* a  = paramIn;
    float* b = a + N;
    int tid = threadIdx.x;
    int cacheIndex = threadIdx.x;
    float   temp = a[tid];
    while (tid < N) 
    {
        //temp += a[tid] * b[tid];
        //temp = a[tid] ;//>= a[tid+1] ? a[tid] : a[tid+1];
        if (temp < a[tid])
            temp = a[tid];
        tid += 32;
    }
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
            //cache[cacheIndex] += cache[cacheIndex + i];
            if (b[cacheIndex] >=  b[cacheIndex + i])
                b[cacheIndex] = b[cacheIndex];
            else
                b[cacheIndex] = b[cacheIndex+i];
            //printf("i=%d,tid1=%d,blockIdx.x=%d,tid=%d,%g,%g\n",
            //       i, tid1,blockIdx.x, cacheIndex, cache[cacheIndex],cache[cacheIndex+1]);
        }
        //__syncthreads();
        i /= 2;
    }

    //if (cacheIndex == 0)
    //{
        //printf("c[blockIdx.x]:%g, :%d\n", cache[0],blockIdx.x);
    //    c[cacheIndex] = cache[0];
    //}
#endif
}
#if 0 
__device__ void VecDot( void* param)
{
    int N = 32;
    float* paramIn = (float*)param;
    float* paramInOrig = (float*)param;
    int size = (int)(*paramIn);
    paramIn = paramIn + 1;
    float* a  = paramIn;
    paramIn = paramIn + size;
    float* b = paramIn;
    paramIn = paramIn + size;
    float* c = paramIn;
    //int tid = threadIdx.x%N + blockIdx.x * blockDim.x;
    int tid = threadIdx.x%N;
    int cacheIndex = threadIdx.x%N;
    float   temp = 0;
    while (tid < size)
    {
        temp += a[tid] * b[tid];
        tid = tid + N;
        //tid += blockDim.x * gridDim.x;
    }
    // set the cache values
    c[cacheIndex] = temp;
    
#if 1     
    // synchronize threads in this block
    //__syncthreads();

    // for reductions, threadsPerBlock must be a power of 2
    // because of the following code
    //int i = blockDim.x/2;
    int i = N/2;
    while (i != 0) {
        if (cacheIndex < i)
            c[cacheIndex] += c[cacheIndex + i];
        //__syncthreads();
        i /= 2;
    }
    //__syncthreads();
    if (cacheIndex == 0)
    {
       //paramInOrig[0] = 44;
       //printf("Val: %f\n", c[0]);
    }
#endif
     //paramInOrig[0] = 44;
}
#endif
#if 0
__global__ void dot( float *a, float *b, float *c ) {
    __shared__ float cache[threadsPerBlock];
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int cacheIndex = threadIdx.x;

    float   temp = 0;
    while (tid < N) {
        temp += a[tid] * b[tid];
        tid += blockDim.x * gridDim.x;
    }
    
    // set the cache values
    cache[cacheIndex] = temp;
    
    // synchronize threads in this block
    __syncthreads();

    // for reductions, threadsPerBlock must be a power of 2
    // because of the following code
    int i = blockDim.x/2;
    while (i != 0) {
        if (cacheIndex < i)
            cache[cacheIndex] += cache[cacheIndex + i];
        __syncthreads();
        i /= 2;
    }

    if (cacheIndex == 0)
        c[blockIdx.x] = cache[0];
}
#endif

