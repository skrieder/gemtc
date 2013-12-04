/*
 * Calculating value of Pi using GeMTC kernel
 */
#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<math.h>
#define SEED 35791246

int main(int argc, char **argv){
    /*
     * NUM_TASKS is the total number of tasks which will be submitted to GeMTC
     * LOOP_SIZE is the total number of tasks submitted to GeMTC queue before watiting for polling for results
     */
     int NUM_TASKS, LOOP_SIZE;
     int niter=0, i ,j;

    /*
     * Timers for benchmarking
     */
     struct timespec start, end;
     double time_spent = 0.0;

    /*
     * Report log for invalid number of arguments
     */
    if (argc > 2){
        NUM_TASKS = atoi(argv[1]);
        LOOP_SIZE = atoi(argv[2]);
        niter = atoi(argv[3]);
    } else {
         printf("This test requires three parameter:\n");
         printf("int NUM_TASKS, int LOOP_SIZE, int ITERATIONS\n");
         printf("int iterations\n");
         printf("where  NUM_TASKS is the total numer of task\n");
         printf("LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
         printf("ITERATIONS is the total numer of task\n");
         exit(1);
    }

    /*
     * Setup GeMTC
     */
    gemtcSetup(25600, 0);

    /*
     * device data pointer
     */
    double *d_params = NULL;

    /*
     * 2*niter random numbers will be generated and we will pass 
     * 2 double variables, 1 for how many iterations and 1 for getting back the
     * value of PI
     */
    int size = (2 + niter*2);

    /*
     * initialize seed for random number generation
     */
    srand(SEED);
  
    /*
     * Allocate host memory
     */ 
    double *h_params = (double*)malloc(sizeof(double)*size);

    /*
     * Geneate random float numbers
     */
    for(i=2; i<size; i++) {
        h_params[i] = (double)rand()/RAND_MAX;
    }

    /*
     * Set number of iterations
     */
    h_params[0] = niter;

    /*
     * Start timer
     */
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);

    for (j = 0; j < NUM_TASKS/LOOP_SIZE; j++) {
        /*
	 * Submit number of jobs = LOOP_SIZE to gemtc
	 */
        for (i = 0; i < LOOP_SIZE; i++) {
            /*
	     * Allocate memory
	     */
            d_params = (double *) gemtcGPUMalloc(size*sizeof(double));
            /*
             * Copy package to gemtc
             */
             gemtcMemcpyHostToDevice(d_params, h_params, sizeof(double)*size);
             gemtcPush(30, 32, i+j*LOOP_SIZE, d_params);
        }
        /*
         * Poll for results
         */
        for(i=0; i<LOOP_SIZE; i++) {
            void *ret=NULL;
            int id;
          
            /*
             * Poll
             */
            while (ret == NULL) {
                gemtcPoll(&id, &ret);
            }
            /*
             * Copy the results back into host
             */
            gemtcMemcpyDeviceToHost(((double*)h_params + 1), 
                                    ((double*)ret + 1), 
                                    sizeof(double));
            /*
             * Free gemtc memory
             */
            gemtcGPUFree(ret);
        }
    }
    /*
     * Stop timer
     */
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    /* 
     * Evaulate time taken for the computation
     */
    time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

    printf("Estimate of pi is %f \n", h_params[1]);
    printf("Time taken %f seconds\n", time_spent);
    /*
     * Cleanup
     */
    gemtcCleanup();
    free(h_params);
    return 0;
}
