/*
 * Benchmarking code for Imogen's ported cukern_FreezeSpeed_hydro() kernel from "gpuImogen/gpuclass/freezeAndPtot.cu" 
 */
#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<math.h>

/*
 * main engine
 * Input data is generated according to "gpuImogen/gpuclass/unitTest.m"
 */
int main(int argc, char **argv){
    /*
     * NUM_TASKS is the total number of tasks which will be submitted to GeMTC
     * LOOP_SIZE is the total number of tasks submitted to GeMTC queue before watiting for polling for results
     * SIMULATION_TYPE is the data-set to choose for benchmarking
     */
    int NUM_TASKS, LOOP_SIZE, SIMULATION_TYPE;

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
    if(argc>3){
        NUM_TASKS = atoi(argv[1]);
        LOOP_SIZE = atoi(argv[2]);
        SIMULATION_TYPE = atoi(argv[3]);
    } else {
        printf("This test requires three parameters:\n");
        printf("int NUM_TASKS, int LOOP_SIZE, int ARRAY_SIZE\n");
        printf("where\n");
        printf("NUM_TASKS is the total number ArrayAtomic tasks to be sent to gemtc\n");
        printf("LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
        printf("SIMULATION_TYPE 1 for 12*12*12 size simulation, 2 for 128*124*119 size simulation; 3 for 333*69*100 size simulation\n");
        exit(1);
    }

    //printf("DEBUG LOG 1\n");
    /*
     * Setup gemtc
     */
    gemtcSetup(25600, 0);

    int i, j, k;
    int size, output_start, output_len;

    /*
     * Set size, output_start and output_len parameters
     * There is a sinle chunk of memory we allocate for all parameters to be passed
     * to and fro from GeMTC for this kernel. All the inputs and output equation
     * parameters are offset in this big chunk. 
     * While copying the result back we don't want to copy the whole chunk back 
     * instead just copy the output equation varaibles, Hence have to calculate 
     * offset for output parameters and their length.
     * There are 5 double variables, 6 cubical data variables and 1 variable of 2 dimention.
     */
    switch(SIMULATION_TYPE) {
        case 1:
            size = 5*sizeof(double) + (12*12*12)*6*sizeof(double) + (12*12)*sizeof(double);
            output_start = 5 + (12*12*12)*5;
            output_len = (12*12*12)*sizeof(double) + (12*12)*sizeof(double);
            break;
        case 2:
            size = 5*sizeof(double) + (128*124*119)*6*sizeof(double)  + (124*119)*sizeof(double);
            output_start = 5 + (128*124*119)*5;
            output_len = (128*124*119)*sizeof(double) + (124*119)*sizeof(double);
            break;
        case 3:
            size = 5*sizeof(double) + (333*69*100)*6*sizeof(double) +  (69*100)*sizeof(double);
            output_start = 5 + (333*69*100)*5;
            output_len = (333*69*100)*sizeof(double) + (69*100)*sizeof(double);
            break;
        default:
            size = 5*sizeof(double) + (12*12*12)*6*sizeof(double) + (12*12)*sizeof(double);
            output_start = 5 + (12*12*12)*5;
            output_len = (12*12*12)*sizeof(double) + (12*12)*sizeof(double);
            break;
    }

    //printf("DEBUG LOG 2\n");
    /*
     * Allocate host memory
     */ 
    double *h_params = (double *) malloc(size);
    memset(h_params, 0, size);

    /*
     * Set nx, ny, nz
     */
    switch(SIMULATION_TYPE) {
        case 1:
            nx = h_params[0] = 12.0;
            ny = h_params[1] = 12.0;
            nz = h_params[2] = 12.0;
            break;
        case 2:
            nx = h_params[0] = 128.0;
            ny = h_params[1] = 124.0;
            nz = h_params[2] = 119.0;
            break;
        case 3:
            nx = h_params[0] = 333.0;
            ny = h_params[1] = 69.0;
            nz = h_params[2] = 100.0;
            break;
        default:
            nx = h_params[0] = 12.0;
            ny = h_params[1] = 12.0;
            nz = h_params[2] = 12.0;
            break;
    }
    //printf("DEBUG LOG 3\n");

    /*
     * ngrid implementation of Matlab
     */
    double* xpos = (double*) malloc(nx*ny*nz*sizeof(double));
    double* ypos = (double*) malloc(nx*ny*nz*sizeof(double));
    double* zpos = (double*) malloc(nx*ny*nz*sizeof(double));
    
    /*
     * Set equation parameter to point to appropriate offset.
     */
    double* rho = (h_params + 3);

    for (i = 0; i < nx; i++) {
        for (j = 0; j < ny; j++) {
            for (k = 0; k < nz; k++) {
                xpos[i*ny*nz + j*nz + k] = (i+1)*2*M_PI/(nx);
                ypos[i*ny*nz + j*nz + k] = (j+1)*2*M_PI/(ny);
                zpos[i*ny*nz + j*nz + k] = (k+1)*2*M_PI/(nz);
                rho[i*ny*nz + j*nz + k] = 1.0;
            }
        }
    }
    //printf("DEBUG LOG 4\n");

    /*
     * Set equation parameter to point to appropriate offset.
     */
    double *E = rho + (nx*ny*nz);
    double *px = E + (nx*ny*nz);
    double *py = px + (nx*ny*nz);
    double *pz = py + (nx*ny*nz);
    double *ptot = pz + (nx*ny*nz);

    /*
     * Set px, py, E, ptot
     */
    for (i = 0; i < nx; i++) {
        for (j = 0; j < ny; j++) {
            for (k = 0; k < nz; k++) {
                px[i*ny*nz + j*nz + k] = sin(xpos[i*ny*nz + j*nz + k]);
                py[i*ny*nz + j*nz + k] = 1 + sin(ypos[i*ny*nz + j*nz + k] + zpos[i*ny*nz + j*nz + k]);
                pz[i*ny*nz + j*nz + k] = cos(zpos[i*ny*nz + j*nz + k]);

                E[i*ny*nz + j*nz + k] = .5 * (px[i*ny*nz + j*nz + k]*px[i*ny*nz + j*nz + k] + py[i*ny*nz + j*nz + k]*py[i*ny*nz + j*nz + k] + pz[i*ny*nz + j*nz + k]*pz[i*ny*nz + j*nz + k])/rho[i*ny*nz + j*nz + k] + 2;

                ptot[i*ny*nz + j*nz + k] = (2/3)*(E[i*ny*nz + j*nz + k] - .5*(px[i*ny*nz + j*nz + k]*px[i*ny*nz + j*nz + k] + py[i*ny*nz + j*nz + k]*py[i*ny*nz + j*nz + k] + pz[i*ny*nz + j*nz + k]*pz[i*ny*nz + j*nz + k])/rho[i*ny*nz + j*nz + k]);
            }
        }
    }

    /*
     * Set values of remaining equation parameters
     */
    double* gamma = ptot + (nx*ny*nz);
    *gamma = 5/3;

    double* cs0 = gamma + 1;
    double var = 1e-5;
    *cs0 = sqrt((5/3)*pow(var, 2/3));

    //printf("SiZE %d\n", rhomin - h_params);
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

        /*
	 * Submit number of jobs = LOOP_SIZE to gemtc
	 */
        for (i = 0; i < LOOP_SIZE; i++){
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
             * 28 is the freezeAndptot kernel
             */
            gemtcPush(28, 32, i+j*LOOP_SIZE, d_params);
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
            //gemtcMemcpyDeviceToHost(h_params + output_start, 
            //                        (double*)ret + output_start, 
            //                        output_len);
            //printf("DEBUG LOG 7\n");
            /*
             * Free gemtc memory
             */
            gemtcGPUFree(ret);
            //printf("DEBUG LOG 8\n");
            ret = NULL;
        }
        //printf("Done\n");
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
    free(xpos);
    free(ypos);
    free(zpos);
    return 0;
}
