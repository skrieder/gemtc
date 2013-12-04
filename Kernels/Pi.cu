/*
 * Program to compute Pi using Monte Carlo methods 
 * TODO:-
 *     Don't pass the randomly computed values from application program
 * Instead generate then here.
 * 
 * Notes:-
 *    The program was created for presentation demo. 
 *
 * Theory:-
 * Any application using Monte Carlo simulation can be migrated to GeMTC
 * and can provide highly efficent results. This is because the amount
 * of data being passed via GeMTC will be less. 
 */
__device__ void gemtc_pi(void *params) 
{
    /*
     * Computed tid
     */
    int tid = threadIdx.x % 32;
    double* paramsIn = (double*)params;

    /*
     * Number of iteration, or number of sample
     */
    int niter = (int)paramsIn[0];

    /*
     * Output variable
     */
    paramsIn = paramsIn + 1;
    double *pi = paramsIn;

    /*
     * Get randomly computed values
     */
    paramsIn = paramsIn + 1;
    double *rand = paramsIn;

    /*
     * Fine to use shared memory here, 32 threads ony
     */
    int* count = (int *) gemtcSharedMemory();;
    count[tid] = 0;
    double x,y;
    int i; /* # of points in the 1st quadrant of unit circle */
    double z;

    for (i=tid; i<niter; i+=32) {
        x = rand[i];
        y = rand[i+niter];
        z = x*x+y*y;
        if (z<=1) {count[tid]++;}
    }
        //printf("count = %d\n", count[tid]);

    /*
     * Apply CUDA reduction to get count summation
     */
    int rounds = 32;
    while((rounds = rounds >> 1) > 0) {
        if(tid < rounds) {
            count[tid] += count[tid + rounds];
        }
        //__syncthreads();
    }

    /*
     * Compute Pi
     */
    if (tid == 0) {
        *pi=(double)count[0]/niter*4;
    }
}
