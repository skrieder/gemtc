/*
 * Benchmarking code for Imogen's ported kernel from "gpuImogen/gpuclass/cudaArrayAtomic.cu" 
 */
#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>

/*
 * main engine
 * Input data is generated within by random number genetation
 */
int main(int argc, char **argv){

    /*
     * NUM_TASKS is the total number of tasks which will be submitted to GeMTC
     * LOOP_SIZE is the total number of tasks submitted to GeMTC queue before watiting for polling for results
     * ARRAY_SIZE is the length of array
     */
    int NUM_TASKS, LOOP_SIZE, ARRAY_SIZE;

    /*
     * Timers for benchmarking
     */
    struct timespec start, end;
    double time_spent =0.0;

    /*
     * Report log for invalid number of arguments
     */
    if (argc > 3) {
        NUM_TASKS = atoi(argv[1]);
	LOOP_SIZE = atoi(argv[2]);
	ARRAY_SIZE = atoi(argv[3]);
    } else {
        printf("This test requires three parameters:\n");
        printf("int NUM_TASKS, int LOOP_SIZE, int ARRAY_SIZE\n");
        printf("where\n");
        printf("NUM_TASKS is the total number ArrayAtomic tasks to be sent to gemtc\n");
        printf("LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
        printf("ARRAY_SIZE is the side length of the matrix that is going to be squared\n");
        exit(1);
    }

    /*
     * Setup gemtc
     */
    gemtcSetup(25600, 0);

    /*
     * Local variables
     */
    int j;

    /*
     * (3 + ARRAY_SIZE) because 1st parameter will select sub-kernel and 2nd will send the threahold
     * 3rd parameter will be size of the arry, lastly the array itself
     */
    double *h_params = (double *) malloc(sizeof(double)*(3 + ARRAY_SIZE));
    memset(h_params, 0, sizeof(double)*(3+ARRAY_SIZE));

    /*
     * Select first sub-kernel
     */
    h_params[0] = 1;

    /*
     * Minimum threshold
     */
    h_params[1] = 0.053;

    /*
     * Array size
     */
    h_params[2] = ARRAY_SIZE;

    /*
     * Generate array of random floating point numbers
     */
    for (j = 3; j < ARRAY_SIZE + 3; j++) {
        h_params[j]= ((double) rand())/INT_MAX;
    }

    /*
     * Purposefully set 1 array parameters to be lessa then minimum
     */
    h_params[5] = .009;

    //printf("Minimum Threshold %f\n", h_params[1]);
    //printf("ORIGINAL ARRAY \n");
    //for(j=3; j<ARRAY_SIZE+3; j++) {
    //  printf("Element %f\n", h_params[j]);
    //}
    printf("\n");

    double *d_params = NULL;
    /*
     * Start benchmarking timer
     */
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);

    for (j = 0; j < NUM_TASKS/LOOP_SIZE; j++) {
        int i;
        h_params[0] = 1;
        h_params[1] = 0.053;
        h_params[2] = ARRAY_SIZE;
        h_params[5] = .009;

        /*
	 * Submit number of jobs = LOOP_SIZE to gemtc
	 */
        for (i = 0; i < LOOP_SIZE; i++) {
            /*
	     * Allocate memory
	     */
            d_params = (double *) gemtcGPUMalloc(sizeof(double)*(3+ARRAY_SIZE));

	    if (!d_params) {
                printf("GeMTC memory allocation failure\n");
	        return 0;
           } else {
              //printf("Submitting j=%d, i=%d, taskID %d\n", j, i, (i+j*LOOP_SIZE));
           }

           /*
            * Copy package to gemtc
            */
           gemtcMemcpyHostToDevice(d_params, h_params, sizeof(double)*(3+ARRAY_SIZE));

           /*
            * 24 is the ArrayAtomic kernel
            */
           gemtcPush(24, 32, i+j*LOOP_SIZE, d_params);
           //gemtcGPUFree(d_params);
        }

        /*
         * Poll for results
         */
        for (i = 0; i < LOOP_SIZE; i++) {
            void *ret=NULL;
            int id;
          
            /*
             * Poll
             */
            while (ret == NULL) {
               gemtcPoll(&id, &ret);
            }
            //printf("Received job %d\n", id);
            /*
             * Copy the results back into host
             */
            gemtcMemcpyDeviceToHost(h_params, 
                                    (double*)ret, 
                                    sizeof(double)*(3+ARRAY_SIZE));
            /*
             * Free gemtc memory
             */
            gemtcGPUFree(ret);
            ret = NULL;
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

    printf(" Time taken %f seconds\n", time_spent);
    printf("\n");
    //printf("NORMALIZED ARRAY \n");
    //for(j=3; j<ARRAY_SIZE+3; j++) {
    //  printf("Element %f\n", h_params[j]);
    //}
    printf("\n");

    /*
     * Cleanup
     */
    gemtcCleanup();
    free(h_params);
    return 0;
}
