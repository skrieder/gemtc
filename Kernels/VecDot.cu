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
    if (tid < N) 
    {
        temp += a[tid] * b[tid];
        //tid += blockDim.x * gridDim.x;
    }
    // set the cache values
    c[cacheIndex] = temp;
    
#if 0     
    // synchronize threads in this block
    __syncthreads();

    // for reductions, threadsPerBlock must be a power of 2
    // because of the following code
    //int i = blockDim.x/2;
    int i = N/2;
    while (i != 0) {
        if (cacheIndex < i)
            c[cacheIndex] += c[cacheIndex + i];
        __syncthreads();
        i /= 2;
    }
    __syncthreads();
    if (cacheIndex == 0)
    {
       paramInOrig[0] = 44;
       printf("Val: %d\n", paramInOrig[0]);
    }
#endif
     paramInOrig[0] = 44;
}

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
