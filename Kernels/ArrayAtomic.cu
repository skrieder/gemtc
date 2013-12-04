/*
 * Application:- Imogen's ported kernel from "gpuImogen/gpuclass/cudaArrayAtomic.cu" 
 * Purpose:-
 *     To perform operation on single array. Useful when parameters like density
 * are required to be kept to have certain minimum value or certain maximum value
 * or require NaNs to be replaced by zeros.
 */ 

/*
 * Shader frequency of GTX 480 
 * Better will be to deriver this in case we are simulation in a different GPU
 * But calling function to derive frequncy so many times will be still expensive
 * Tip:- Get this from the caller as input parameter.
 */
#define SHADER_CLOCK 1401000
/*
 * This will set all array elements with less than minimum 
 * threshold to value specified in input parameter
 */
__device__ void ArraySetMin(void *params)
{
    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //clock_t start, stop;
    //start = clock();
    //printf("Thread %d\n", threadIdx.x);
    /*
     * CUDA Threads
     */
    int warp_size = 32;

    /*
     * Get thread tid (we should keep it from 0-31 range only)
     */
    int tid = threadIdx.x % warp_size;

    /*
     * Get input parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     */
    paramsIn = paramsIn + 1;

    /*
     * Get minimum threshold parameter
     */
    double min = (double)paramsIn[0];

    /*
     * Get number of elements in the array
     */
    paramsIn = paramsIn + 1;
    int n   = (int)paramsIn[0];

    /*
     * Get the array
     */
    paramsIn       = paramsIn + 1;
    double *array  = paramsIn;

    /*
     * Loop and set values
     */
    while (tid < n) {
        if (array[tid] < min) {
            array[tid] = min;
        }
        //printf("tid = %d, n = %d\n", tid, n);
        //printf("incrementing Thread %d\n", threadIdx.x);
        /*
         * Skip next 32 entries, other threads will take care of them
         */
        tid += warp_size;
    }
    /*
     * No need of synchronization within 1 warp
     */
    //__syncthreads();
    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //printf("Thread %d\n", threadIdx.x);
    //stop = clock();
    //float time = (float)(stop - start)/(float)SHADER_CLOCK;
    //printf("Time taken %f ms\n", time);    
}

/*
 * This will set all array elements with greater than maximum 
 * threshold to value specified in input parameter
 */
__device__ void ArraySetMax(void *params)
{
    /*
     * CUDA Threads
     */
    int warp_size = 32;
    int tid = threadIdx.x % warp_size;

    /*
     * Get input parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     */
    paramsIn = paramsIn + 1;

    /*
     * Get maximum threshold
     */
    double max = (double)paramsIn[0];

    /*
     * Get number of array elements
     */
    paramsIn = paramsIn + 1;
    int n   = (int)paramsIn[0];

    /*
     * Get the array itself
     */
    paramsIn       = paramsIn + 1;
    double *array = paramsIn;

    /*
     * Loop and set values
     */
    while (tid < n) {
        if (array[tid] > max) {
            array[tid] = max;
        }
        /*
         * Skip next 32 entries, other threads will take care of them
         */
        tid += warp_size;
    }
}

/*
 * This will set all array elements which are not a number
 * to value specified in input parameter
 */
__device__ void ArraySetNaN(void *params)
{
    /*
     * CUDA Threads
     */
    int warp_size = 32;
    int tid = threadIdx.x % warp_size;

    /*
     * Get input parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     */
    paramsIn = paramsIn + 1;

    /*
     * Get fixed values to replace NaNs
     */
    double fixval = (double)paramsIn[0];

    /*
     * Get number of array elements
     */
    paramsIn = paramsIn + 1;
    int n   = (int)paramsIn[0];

    /*
     * Get the array itself
     */
    paramsIn       = paramsIn + 1;
    double *array = paramsIn;

    /*
     * Loop and set values
     */
    while (tid < n) {
        if (isnan(array[tid])) {
            array[tid] = fixval;
        }
        /*
         * Skip next 32 entries, other threads will take care of them
         */
        tid += warp_size;
    }
}

/*
 * Sub-kernel selection function, Superkernel will call this function only
 */
__device__ void ArrayAtomic(void *params)
{
    /*
     * Get the selection option
     */
    double *operation = (double*)params;

    switch((int)*operation) {
    /*
     * Call set min for selection option 1
     */
    case 1: ArraySetMin(params);
        break;
    /*
     * Call set max for selection option 2
     */
    case 2: ArraySetMax(params);
        break;
    /*
     * Call set NaN for selection option 3
     */
    case 3: ArraySetNaN(params);
        break;
    }
}
