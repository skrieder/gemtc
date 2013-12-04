/*
 * Benchmarking code for Imogen's ported cukern_TVDStep_hydro_uniform() kernel from "gpuImogen/gpuclass/cudaFluidTVD.cu" 
 */
#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<math.h>

/*
 * main engine
 */
int main(int argc, char **argv){
    /*
     * NUM_TASKS is the total number of tasks which will be submitted to GeMTC
     * LOOP_SIZE is the total number of tasks submitted to GeMTC queue before watiting for polling for results
     */
    int NUM_TASKS, LOOP_SIZE;

    /*
     * Timers for benchmarking
     */
    struct timespec start, end;
    double time_spent = 0.0;
    /*
     * Data-set dimensions
     */
    int nx, ny, nz;

    /*
     * Report log for invalid number of arguments
     */
    if (argc > 2){
        NUM_TASKS = atoi(argv[1]);
        LOOP_SIZE = atoi(argv[2]);
    } else {
        printf("This test requires three parameters:\n");
        printf("int NUM_TASKS, int LOOP_SIZE, int ARRAY_SIZE\n");
        printf("where\n");
        printf("NUM_TASKS is the total number ArrayAtomic tasks to be sent to gemtc\n");
        printf("LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
        exit(1);
    }

    //printf("DEBUG LOG 1\n");
    /*
     * Setup gemtc
     */
    gemtcSetup(25600, 0);

    int i, j;
    int size, output_start, output_len;

    /*
     * Set size, output_start and output_len parameters
     * There is a sinle chunk of memory we allocate for all parameters to be passed
     * to and fro from GeMTC for this kernel. All the inputs and output equation
     * parameters are offset in this big chunk. 
     * While copying the result back we don't want to copy the whole chunk back 
     * instead just copy the output equation varaibles, Hence have to calculate 
     * offset for output parameters and their length.
     * There are 6 double variables, 11 cubical data variables and 1 variable of 2 dimention.
     */
    size = 6*sizeof(double) + (410*280*1)*11*sizeof(double) + (280*1)*sizeof(double);
    output_start = 3 + (410*280*1)*6;
    output_len = (410*280*1)*5*sizeof(double);

    //printf("DEBUG LOG 2\n");
    /*
     * Allocate host memory
     */ 
    double *h_params = (double *) malloc(size);
    memset(h_params, 0, size);

    /*
     * Set nx, ny, nz
     */
    nx = h_params[0] = 410.0;
    ny = h_params[1] = 280.0;
    nz = h_params[2] = 1.0;

    //printf("DEBUG LOG 3\n");

    /*
     * Set input variables
     */
    double* rho = (h_params + 3);
    double* E = rho + (nx*ny*nz);
    double* px = E + (nx*ny*nz);
    double* py = px + (nx*ny*nz);
    double* pz = py + (nx*ny*nz);
    double* P = pz + (nx*ny*nz);
    double* rho_out = P + (nx*ny*nz);
    double* E_out = rho_out + (nx*ny*nz);
    double* px_out = E_out + (nx*ny*nz);
    double* py_out = px_out + (nx*ny*nz);
    double* pz_out = py_out + (nx*ny*nz);
    double* Cfreeze = pz_out + (nx*ny*nz);
    double* lambda = Cfreeze + ny*nz;
    double* rhomin = lambda + 1;
    double* gamma = rhomin + 1;

    *lambda = 0.1;
    *gamma = 5/3;
    *rhomin = 1e-5;

    /*
     * Read data from files
     */
    FILE *f_rho = fopen("../data/rho.txt", "r");
    if(!f_rho) {
        printf("Unable to open ../data/rho.txt\n");
    }
    FILE *f_E = fopen("../data/E.txt", "r");
    if(!f_E) {
        printf("Unable to ../data/open E.txt\n");
    }
    FILE *f_px = fopen("../data/px.txt", "r");
    if(!f_px) {
        printf("Unable to ../data/open px.txt\n");
    }
    FILE *f_py = fopen("../data/py.txt", "r");
    if(!f_py) {
        printf("Unable to open ../data/py.txt\n");
    }
    FILE *f_pz = fopen("../data/pz.txt", "r");
    if(!f_pz) {
        printf("Unable to open ../data/pz.txt\n");
    }

    for(i = 0; i < 410; i++) {
        for(j = 0; j < 280; j++) {
            fscanf(f_rho, "%lf", &rho[i*280 + j]);
            fscanf(f_E, "%lf", &E[i*280 + j]);
            fscanf(f_px, "%lf", &px[i*280 + j]);
            fscanf(f_py, "%lf", &py[i*280 + j]);
            fscanf(f_pz, "%lf", &pz[i*280 + j]);
        }
        //printf("Integer %d\n", i);
    }
 
    /*
     * Close files
     */ 
    fclose(f_rho); 
    fclose(f_E); 
    fclose(f_px); 
    fclose(f_py); 
    fclose(f_pz); 
    
    /*
     * Always print bytes without it we can't analyse benchmark properly
     */
    printf("SiZE %d\n", size);

    /*
     * GeMTC data pointer
     */
    double *d_params = NULL;
    //double *d_params = (double *) gemtcGPUMalloc(size);
    /*
     * Start benchmarking timer
     */
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);
    for (j = 0; j < NUM_TASKS/LOOP_SIZE; j++) {
        /*
         * memset the equation output parameters
         */
        memset((double*)h_params + output_start, 0, output_len);
        //printf(" j is %d\n",j);

        /*
	 * Submit number of jobs = LOOP_SIZE to gemtc
	 */
        for(i=0; i<LOOP_SIZE; i++){
            /*
	     * Allocate memory
	     */
            d_params = (double *) gemtcGPUMalloc(size);
            if (d_params == NULL) {
                printf("Unable to allocate memory\n");
            }

            /*
             * Copy package to gemtc
             */
            gemtcMemcpyHostToDevice(d_params, h_params, size);
            /*
             * 29 is the FluidTVD kernel
             */
            gemtcPush(29, 32, i+j*LOOP_SIZE, d_params);
            //printf("Pushing %d\n", i);
            //gemtcGPUFree(d_params);
        }
        //printf("DEBUG LOG 6\n");

        /*
         * Poll for results
         */
        for (i = 0; i < LOOP_SIZE; i++) {
            void *ret=NULL;
            int id;
            /*
             * Poll
             */
            while (ret == NULL){
            //printf("POLLING\n");
                gemtcPoll(&id, &ret);
            }
            /*
             * Copy the results back into host
             */
            gemtcMemcpyDeviceToHost(((double*)h_params + output_start), 
                                    ((double*)ret + output_start), 
                                    output_len);
            //printf("DEBUG LOG 7\n");
            /*
             * Free gemtc memory
             */
            gemtcGPUFree(ret);
            //printf("DEBUG LOG 8\n");
            ret = NULL;
        }
    }

    //printf("DEBUG LOG 9\n");
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
    /*
     * Cleanup
     */
    gemtcCleanup();

    free(h_params);
    return 0;
}
