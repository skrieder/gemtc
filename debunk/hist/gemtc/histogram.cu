#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#define BIN_COUNT 256
//#define NUM_RUNS  5
//#define AVG_RUNS 10.0 
#define BYTE_COUNT 1000
#include <helper_functions.h>
#include <cuda_runtime.h>

int main(int argc, char **argv){
    int NUM_TASKS, LOOP_SIZE;
    uint byteCount = BYTE_COUNT;
    int Overfill = 0;
    if (argc != 3){
        printf("invalid parameters, use: <NUM_INPUTS> <NUM_TEST>\n");
    return -1;
    }
    int NUM_RUNS = atoi(argv[1]);
    int AVG_RUNS = atoi(argv[2]);    


    cudaDeviceProp devProp;
    cudaGetDeviceProperties(&devProp, 0);
    StopWatchInterface *hTimer = NULL;
    int iter,warps;
    int blocks = devProp.multiProcessorCount;
    sdkCreateTimer(&hTimer);
    
    //Starting Iterating
    for(iter=0; iter < NUM_RUNS; iter++) {
        if(Overfill==1){
            warps = devProp.maxThreadsPerBlock/32;
        }
        if(Overfill==0){
            int coresPerSM = _ConvertSMVer2Cores(devProp.major, devProp.minor);
            warps = coresPerSM/16;  //A warp runs on 16 cores
        }
        if(Overfill==2){
            warps =1;
            blocks = 1;
        }
        NUM_TASKS = warps * blocks*AVG_RUNS;
        LOOP_SIZE = 1;
        byteCount = byteCount / NUM_TASKS;
        
        gemtcSetup(25600, Overfill);
        int d_size = sizeof(unsigned int) * byteCount;
        int h_size = sizeof(int) * BIN_COUNT;
        int size = 1 + d_size + h_size;
        int j;
        int k;
        uint *h_params = (uint *) malloc(size);
        double dAvgSecs;
        
        
        srand(2009);
        h_params[0] = byteCount;
        //printf("ByteCount :%d , NUM_TASKS : %d \n", byteCount,NUM_TASKS);
        for (uint i = 1; i <= byteCount; i++)
        {
            h_params[i] = rand() % 256;
        }
        sdkResetTimer(&hTimer);
        sdkStartTimer(&hTimer);
        //for(k=0; k < AVG_RUNS ; k++) {
            for(j=0; j <NUM_TASKS; j++){
                //for(i=0; i < LOOP_SIZE; i++){
                    uint *d_params = (uint *) gemtcGPUMalloc(size);
                    gemtcMemcpyHostToDevice(d_params, h_params, size);
                    gemtcPush(34, 32, j*LOOP_SIZE, d_params);
                //}
                
                /*for(i=0; i < LOOP_SIZE; i++){
                    void *ret=NULL;
                    int id;
                    while(ret==NULL){
                        gemtcPoll(&id, &ret);
                    }
                    gemtcMemcpyDeviceToHost(h_params, ret, size);
                    gemtcGPUFree(ret);
                }*/
            }
		    void *ret=NULL;
                    int id;
                    while(ret==NULL){
                        gemtcPoll(&id, &ret);
                    }
                    gemtcMemcpyDeviceToHost(h_params, ret, size);
                    gemtcGPUFree(ret);

        //}
        free(h_params);
        sdkStopTimer(&hTimer);
        dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer);///(double) AVG_RUNS;
        unsigned int problem_size = (byteCount * 4) * NUM_TASKS;
        
        //dAvgSecs = dAvgSecs/(NUM_TASKS/LOOP_SIZE);
        printf("%u \t%.4f\t%.5f\n",
        problem_size,(1.0e-6 * (double) problem_size / dAvgSecs), dAvgSecs);
        byteCount = byteCount * NUM_TASKS * 10;
        gemtcCleanup();
    }
    sdkDeleteTimer(&hTimer);
    return 0;
}
