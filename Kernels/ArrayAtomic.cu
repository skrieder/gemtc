/*
 * Application:- Imogen
 * Purpose:-
 *     To perform operation on single array. Useful when parameters like density
 * are required to be kept to a minimum value or NaNs or replaced by zeros.
 */ 

/*
 * This will set all array elements with less than minimum 
 * threshold to value specified in input parameter
 */
__device__ void ArraySetMin(void *params)
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

    double min = (double)paramsIn[0];

    paramsIn = paramsIn + 1;
    int n   = (int)paramsIn[0];

    paramsIn       = paramsIn + 1;
    double *array  = paramsIn;

    while (tid < n) {
        if (array[tid] < min) {
            array[tid] = min;
        }
        tid += warp_size;
    }
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

    double max       = (double)paramsIn[0];

    paramsIn = paramsIn + 1;
    int n   = (int)paramsIn[0];

    paramsIn       = paramsIn + 1;
    double *array = paramsIn;

    while (tid < n) {
        if (array[tid] > max) {
            array[tid] = max;
        }
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

    double fixval    = (double)paramsIn[0];

    paramsIn = paramsIn + 1;
    int n   = (int)paramsIn[0];

    paramsIn       = paramsIn + 1;
    double *array = paramsIn;

    while (tid < n) {
        if (isnan(array[tid])) {
            array[tid] = fixval;
        }
        tid += warp_size;
    }
}

__device__ void ArrayAtomic(void *params)
{
    double *operation = (double*)params;

    switch((int)*operation) {
    case 1: ArraySetMin(params);
        break;
    case 2: ArraySetMax(params);
        break;
    case 3: ArraySetNaN(params);
        break;
    }
}
