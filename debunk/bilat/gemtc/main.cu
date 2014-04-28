#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include <helper_functions.h>
#include <cuda_runtime.h>
#define NUM_TEST 10
#define TEST_RUN 7
#define IMAGE_SIZE 1024

typedef struct {
        float R;
        float G;
        float B;

} RGB;



int main(int argc, char **argv){
    int NUM_TASKS, LOOP_SIZE;
    int Overfill = 0;
    if (argc != 5){
        printf("invalid parameters, use:  <channels> <neighborhood radius> <spatial sigma> <range sigma>\n");
	return -1;
    }
    const unsigned int channels = atoi(argv[1]);
    unsigned int radius = atoi(argv[2]);
    float sigma_spatial = (float)atof(argv[3]);
    float sigma_range = (float)atof(argv[4]);
	 
    unsigned int width = IMAGE_SIZE;
    unsigned int height = IMAGE_SIZE;
    
    cudaDeviceProp devProp;
    cudaGetDeviceProperties(&devProp, 0);
    StopWatchInterface *hTimer = NULL;
    sdkCreateTimer(&hTimer);
    
    /*int warps;
    int blocks = devProp.multiProcessorCount;
	
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
     */
	for(int i = 0; i < TEST_RUN; i++)
    {
		int d_size = sizeof(RGB) * width * height;
		
        int size = 2 + 2*d_size;
		
        RGB *data=(RGB *) malloc (size);
        
		RGB r_size;
		r_size.R = width * height;
		r_size.G = width;
		r_size.B = height;
		
		data[0] = r_size;
				
		RGB r;
		r.R = channels;
		r.G =  radius;
		r.B = sigma_spatial;
		data[1] = r;
		
		RGB r1;
		r1.R = sigma_range;
		data[2] = r1;
		
		
		for(int j = 3; j < (width * height) + 3; j++)
         {
            RGB c;
            c.R = rand() % 255;
            c.G = rand() % 255;
            c.B =  rand() % 255;
            data[j] = c;
         }

		gemtcSetup(25600, Overfill);
		
		
		sdkResetTimer(&hTimer);
		sdkStartTimer(&hTimer);
		
		for(int k=0; k < NUM_TEST ; k++) {
            for(int j=0; j <NUM_TASKS/LOOP_SIZE; j++){
                int i;
                for(i=0; i < LOOP_SIZE; i++){
                    float3 *d_params = (float3 *) gemtcGPUMalloc(size);
                    gemtcMemcpyHostToDevice(d_params, data, size);
                    gemtcPush(34, 32, i+j*LOOP_SIZE, d_params);
                }
                
                for(i=0; i < LOOP_SIZE; i++){
                    void *ret=NULL;
                    int id;
                    while(ret==NULL){
                        gemtcPoll(&id, &ret);
                    }
                    gemtcMemcpyDeviceToHost(data, ret, size);
                    gemtcGPUFree(ret);
                }
            }
        }
		free(data);
		sdkStopTimer(&hTimer);
		double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / (double) NUM_TEST;
		printf("%u\t%.5f\n",width*height, dAvgSecs);
		gemtcCleanup();
		width *= 2;
		
	}
    sdkDeleteTimer(&hTimer);
    return 0;	
	
}

