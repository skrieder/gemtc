/*
 * Application:- Imogen's ported kernel from "gpuImogen/gpuclass/cudaArrayRotate.cu"
 * Purpose:-
 *     To perform array rotation.
 */

/*
 * Shader frequency of GTX 480 
 * Better will be to deriver this in case we are simulation in a different GPU
 * But calling function to derive frequncy so many times will be still expensive
 * Tip:- Get this from the caller as input parameter.
 */
#define SHADER_CLOCK 1401000

/*
 * Transpose 2D array
 */
__device__ void ArrayTranspose2D(void *params)
{
    int j;

    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //clock_t start, stop;
    //start = clock();
    //printf("Initiating\n");

    /*
     * Declare shared array, this is shared between all threads
     * Do NOT use it, it will restrict the maximum data-set on which we can work.
     * Till mid-semester report we were using it.
     */
    //double *tmp = (double *) gemtcSharedMemory();

    /*
     * Get input parameters, Unpack parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     * Remmeber that while unpacking we will be deriving offsets.
     * These offsets are the positions where we will find input parameters.
     * Be careful on pointer arithmetic. If you get segmentation-faul this is 
     * the first place to check for.
     */
    paramsIn = paramsIn + 1;
    
    /*
     * Get nx (x-dimension)
     */
    int nx = (int)paramsIn[0];
    
    /*
     * Get ny (y-dimension)
     */
    paramsIn = paramsIn + 1;
    int ny = (int)paramsIn[0];

    /*
     * Get source 2D array
     */
    paramsIn = paramsIn + 1;
    double* src = (double*)paramsIn;

    /*
     * Get destination 2D array
     */
    paramsIn = paramsIn + nx*ny;
    double* dst = (double*)paramsIn;

    /*
     * CUDA Threads
     */
    int warp_size = 32;
    /*
     * Get thread tid (we should keep it from 0-31 range only)
     */
    int tid = threadIdx.x % warp_size;

    /*
     * Fill the destination 2-D array in rotated fashion.
     * One thread incharge of 1 row, hence skip next 32 entries 
     * for each thread.
     */
    for (; tid < nx; tid+=warp_size) {
        for (j = 0; j < ny; j++) {
            dst[tid*ny + j] = src[j*nx + tid];
        }
    }

    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //printf("DONE\n");
    //stop = clock();
    //float time = (float)(stop - start)/(float)SHADER_CLOCK;
    //printf("Time taken %f ms\n", time);    
}

__device__ void ArrayExchangeY(void *params)
{
    /*
     * Declare shared array, this is shared between all threads
     */
    double *tmp = (double *) gemtcSharedMemory();

    /*
     * Get input parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     */
    paramsIn = paramsIn + 1;
    int nx = (int)paramsIn[0];
    
    paramsIn = paramsIn + 1;
    int ny = (int)paramsIn[0];

    paramsIn = paramsIn + 1;
    int nz = (int)paramsIn[0];

    paramsIn = paramsIn + 1;
    double* src = (double*)paramsIn;

    paramsIn = paramsIn + nx*ny;
    double* dst = (double*)paramsIn;

    /*
     * CUDA Threads
     */
    int warp_size = 32;
    int tid = threadIdx.x % warp_size;

    /*
     * Local parameters
     */
    int myx       = tid;
    int myy       = threadIdx.y;
    int myz       = 0;
    int myAddr    = myx + nx*myy;

    /*
     * Each thread has to copy data from source into shared memory 
     */
    while (myz < nz) {
       /*
        * For each z dimension's iteration, save data into 
        * temporary shared memory
        */
        myx = tid;
        while (myx < nx) {
            myy = threadIdx.y;
            while (myy < ny) {
                myAddr = myx + nx*myy + (nx*ny)*(myz);
                *((double*)tmp + myy*ny + myx) = src[myAddr];
                myy++;
            }
            myx += warp_size;
        }

        /*
         * Synchronize
         */
        //__syncthreads();

        myx = tid;
        while (myx < nx) {
            myy = threadIdx.y;
            while (myy < ny) {
                myAddr = myx + nx*myy + (nx*ny)*(myz);
                dst[myAddr] = *((double*)tmp + myx*ny + myy);
                myy++;
            }
            myx += warp_size;
        }
        /*
         * Synchronize
         */
        //__syncthreads();

        myz++;
    }
}

__device__ void ArrayExchangeZ(void *params)
{
    /*
     * Declare shared array, this is shared between all threads
     */
    double *tmp = (double *) gemtcSharedMemory();

    /*
     * Get input parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     */
    paramsIn = paramsIn + 1;
    int nx = (int)paramsIn[0];
    
    paramsIn = paramsIn + 1;
    int ny = (int)paramsIn[0];

    paramsIn = paramsIn + 1;
    int nz = (int)paramsIn[0];

    paramsIn = paramsIn + 1;
    double* src = (double*)paramsIn;

    paramsIn = paramsIn + nx*ny;
    double* dst = (double*)paramsIn;

    /*
     * CUDA Threads
     */
    int warp_size = 32;
    int tid = threadIdx.x % warp_size;

    /*
     * Local parameters
     */
    int myx       = tid;
    int myz       = tid + threadIdx.y;
    int myy       = 0;
    int myAddr    = myx + nx*myy;

    /*
     * Each thread has to copy data from source into shared memory 
     */
    while (myy < ny) {
       /*
        * For each y dimension's iteration, save data into 
        * temporary shared memory
        */
        myx = tid;
        while (myx < nx) {
            myz = tid + threadIdx.y;
            while (myz < nz) {
                myAddr = myx + nx*myy + (nx*ny)*(myz);
                *((double*)tmp + myy*ny + myx) = src[myAddr];
                myz++;
            }
            myx += warp_size;
        }

        /*
         * Synchronize
         */
        //__syncthreads();

        myx = tid;
        while (myx < nx) {
            myz = tid + threadIdx.y;
            while (myz < nz) {
                myAddr = myx + nx*myy + (nx*ny)*(myz);
                dst[myAddr] = *((double*)tmp + myx*ny + myy);
                myz++;
            }
            myx += warp_size;
        }
       
        /*
         * Synchronize
         */
        //__syncthreads();

        myz++;
    }
}

/*
 * Sub-kernel selection function, Superkernel will call this function only
 */
__device__ void ArrayRotate(void *params)
{
    /*
     * Get the selection option
     */
    double *operation = (double*)params;

    switch((int)*operation) {
    /*
     * Call exchange y for selection option 1
     */
    case 1:
        ArrayExchangeY(params);
        break;
    /*
     * Call exchange z for selection option 1
     */
    case 2:
        ArrayExchangeZ(params);
        break;
    /*
     * Call exchange transpose2D for selection option 1
     */
    case 3:
        ArrayTranspose2D(params);
        break;
    };
}
