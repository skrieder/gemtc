/*
 * Benchmarking code for Imogen's ported kernel from "gpuImogen/gpuclass/cudaArrayRotate.cu"
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
    int NUM_TASKS, LOOP_SIZE, MATRIX_SIZE;

    struct timespec start, end;
    double time_spent =0.0;

    if (argc > 3) {
        NUM_TASKS = atoi(argv[1]);
        LOOP_SIZE = atoi(argv[2]);
        MATRIX_SIZE = atoi(argv[3]);
    } else {
        printf("This test requires three parameters:\n");
        printf("int NUM_TASKS, int LOOP_SIZE, int ARRAY_SIZE\n");
        printf("where\n");
        printf("NUM_TASKS is the total number ArrayAtomic tasks to be sent to gemtc\n");
        printf("LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
        printf("MATRIX_SIZE is the side length of the matrix that is going to be squared\n");
        exit(1);
    }

    /*
     * Setup gemtc
     */
    gemtcSetup(25600, 0);

    /*
     * Local variables
     */
    int i, j;

    /*
     * (3 + MATRIX_SIZE*MATRIX_SIZE) because 1st parameter will select sub-kernel 
     * 2nd and 3rd parameter gives matrix dimensions nx and ny, finally the matrix
     */
    double *h_params = (double *) malloc(sizeof(double)*(3+MATRIX_SIZE*MATRIX_SIZE));
    memset(h_params, 0, sizeof(double)*(3+MATRIX_SIZE*MATRIX_SIZE));

    /*
     * Select sub-kernel to select array2D transpose
     */
    h_params[0] = 3;

    /*
     * Dimension nx
     */

    h_params[1] = MATRIX_SIZE;
    /*
     * Dimension ny
     */
    h_params[2] = MATRIX_SIZE;

    /*
     * Generate random matrix
     */
    for (j = 3; j < MATRIX_SIZE*MATRIX_SIZE + 3; j++) {
        h_params[j]= ((double) rand())/INT_MAX;
    }

  //printf("ORIGINAL ARRAY \n");
  //for(j=3; j<(MATRIX_SIZE*MATRIX_SIZE+3); j++) {
  //  if (((j - 3) % MATRIX_SIZE) == 0)
  //    printf("\n");
  //  printf(" %f", h_params[j]);
  //}
  //printf("\nBEGINING");

    double *d_params = NULL;

    /*
     * Start benchmarking timer
     */
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);

    /*
     * Strat processing 
     */
    for (j = 0; j < NUM_TASKS/LOOP_SIZE; j++) {
        for(i=0; i<LOOP_SIZE; i++){
            /*
	     * Allocate memory
	     */
            //printf("Allocating memory\n");
            d_params = (double *) gemtcGPUMalloc(sizeof(double)*(3+2*MATRIX_SIZE*MATRIX_SIZE));

           /*
            * Copy package to gemtc
            */
            gemtcMemcpyHostToDevice(d_params, h_params, sizeof(double)*(3+MATRIX_SIZE*MATRIX_SIZE));
           /*
            * 25 is the ArrayRotate kernel
            */
            gemtcPush(25, 32, i+j*LOOP_SIZE, d_params);
            //printf("Pusing job\n");
            //gemtcGPUFree(d_params);
        }

        /*
         * Poll for results
         */
        //printf("Iteration j = %d\n", j);
        for (i = 0; i < LOOP_SIZE; i++) {
            void *ret=NULL;
            int id;
            /*
             * Poll
             */
            while (ret == NULL) {
                gemtcPoll(&id, &ret);
            }
            //printf("Got job\n");
            /*
             * Copy the results back into host
             */
            gemtcMemcpyDeviceToHost(h_params + 3, 
                                    (double*)ret + 3 + MATRIX_SIZE*MATRIX_SIZE, 
                                    sizeof(double)*(MATRIX_SIZE*MATRIX_SIZE));

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
    //printf("NEW ARRAY \n");
    //for(j=3; j<MATRIX_SIZE*MATRIX_SIZE+3; j++) {
    //  if (((j - 3) % MATRIX_SIZE) == 0)
    //    printf("\n");
    //  printf(" %f", h_params[j]);
    //}
    printf("\n");
    /*
     * Cleanup
     */
    gemtcCleanup();
    free(h_params);
    return 0;
}
