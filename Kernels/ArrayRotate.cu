/*
 * Application:- Imogen
 * Purpose:-
 *     To perform array rotation.
 */

/*
 * Maximum size of the array which can be entertained is 32*32
 * In case more thant that is needed we need to increase the below
 * definition
 */
/*
 * Transpose 2D array
 */
__device__ void ArrayTranspose2D(void *params)
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
    int myx    = tid;
    int myy    = threadIdx.y;
    int myAddr = myx*ny + myy;

    /*
     * Each thread has to copy data from source into shared memory 
     */
    while (myx < nx) {
        myy = threadIdx.y;
        while (myy < ny) {
            myAddr = myx*ny + myy;
            tmp[myy*ny + myx] = src[myAddr];
            myy++;
        }
        myx += warp_size;
    }

    /*
     * No need to sync within warp? Sync up
     * http://stackoverflow.com/questions/10205245/cuda-syncthreads-usage-within-a-warp ?
     */
    //__syncthreads();
#if 1
    myx    = tid;
    myy    = threadIdx.y;
    myAddr = myx*ny + myy;

    /*
     * Transpose using the shared memory 
     */
    while (myx < nx) {
        myy = threadIdx.y;
        while (myy < ny) {
            myAddr = myx*ny + myy;
            dst[myAddr] = tmp[myx*ny + myy];
            myy++;
        }
        myx += warp_size;
    }
#endif
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

__device__ void ArrayRotate(void *params)
{
    double *operation = (double*)params;

    switch((int)*operation) {
    case 1:
        ArrayExchangeY(params);
        break;
    case 2:
        ArrayExchangeZ(params);
        break;
    case 3:
        ArrayTranspose2D(params);
        break;
    };
}
