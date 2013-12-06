/*
 * Program to reproduce memory bug in GeMTC
 */
#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<math.h>

int main(int argc, char **argv){
    int i,j;

    /*
     * Allocate host memory approx 90 MB
     */
    double *h_params = (double*)malloc(90778952);
    //memset(h_params, 0, 90778952);

    /*
     * Setup GeMTC
     */
    gemtcSetup(25600, 0);

    /*
     * Device memory pointers
     */
    double *d_params = NULL;
    j = 0;

    /*
     * Infinite loop but we will hang in second iteration itself
     */
    while(1) {
        /*
         * Submit 10 tasks to GeMTC
         */
        for(i=0; i<10; i++){
            printf("Allocating memory i=%d, iteration=%d\n", i, j);
            d_params = (double *) gemtcGPUMalloc(90778952);
            if (d_params == NULL) {
                printf("Unable to allocate memory\n");
            }
            printf("Done Allocating memory\n");

            /*
             * Copy memory to gemtc
             */
            gemtcMemcpyHostToDevice(d_params, h_params, 90778952);
            /*
             * TaskType (GEMTC_MAX_KERNELS + 1)  will be absent in Gemtc, hence will return immediately
             */
            gemtcPush((GEMTC_MAX_KERNELS + 1), 32, i+j*10, d_params);
            printf("Submitting job %d\n", (i+j*10));
        }
        printf(" Submission for iteration %d complete\n", j);

        /*
         * Get back results
         */
        for(i=0; i<10; i++) {
            void *ret=NULL;
            int id;
            while(ret==NULL){
                gemtcPoll(&id, &ret);
            }
            /*
             * Free memory
             */
            gemtcGPUFree(ret);
            printf(" Freed %d \n", i);
            ret = NULL;
        }
        printf("Iteration %d complete\n", j);
        j++;
    }
    /*
     * Unreachable code
     */
    gemtcCleanup();
    return 0;
}
