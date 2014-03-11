// CUDA Runtime
#include <cuda_runtime.h>

// Utility and system includes
#include "helper_cuda.h"
#include "helper_functions.h"  // helper for shared that are common to CUDA SDK samples

// project include
#include "histogram_common.h"

const int numRuns = 7;
static char *sSDKsample = "[histogram]\0";

int main(int argc, char **argv)
{
    uchar *h_Data;
    uint  *h_HistogramCPU, *h_HistogramGPU;
    uchar *d_Data;
    uint  *d_Histogram;
    StopWatchInterface *hTimer = NULL;
    int PassFailFlag = 1;
    uint byteCount = 1000;
    uint uiSizeMult = 1;

    cudaDeviceProp deviceProp;
    deviceProp.major = 0;
    deviceProp.minor = 0;

    // set logfile name and start logs
   // printf("[%s] - Starting...\n", sSDKsample);


    //Use command-line specified CUDA device, otherwise use device with highest Gflops/s
    int dev = findCudaDevice(argc, (const char **)argv);

    checkCudaErrors(cudaGetDeviceProperties(&deviceProp, dev));

    //printf("CUDA device [%s] has %d Multi-Processors, Compute %d.%d\n",
      //     deviceProp.name, deviceProp.multiProcessorCount, deviceProp.major, deviceProp.minor);

    int version = deviceProp.major * 0x10 + deviceProp.minor;

    if (version < 0x11)
    {
        printf("There is no device supporting a minimum of CUDA compute capability 1.1 for this SDK sample\n");
        cudaDeviceReset();
        exit(EXIT_SUCCESS);
    }

   sdkCreateTimer(&hTimer);

    {
        initHistogram64();

        //printf("Running 64-bin GPU histogram for %u bytes (%u runs)...\n\n", byteCount, numRuns);

        for (int iter = 0; iter < numRuns; iter++)
        {
		sdkResetTimer(&hTimer);
	        sdkStartTimer(&hTimer);
		//printf("Initializing data...\n");
    		h_Data         = (uchar *)malloc(byteCount);
	    	h_HistogramCPU = (uint *)malloc(HISTOGRAM256_BIN_COUNT * sizeof(uint));
    		h_HistogramGPU = (uint *)malloc(HISTOGRAM256_BIN_COUNT * sizeof(uint));

	    	//printf("...generating input data\n");
    		srand(2009);

	   	 for (uint i = 0; i < byteCount; i++)
    		{
        		h_Data[i] = rand() % 256;
	    	}	

    		//printf("...allocating GPU memory and copying input data\n");
	    	checkCudaErrors(cudaMalloc((void **)&d_Data, byteCount));
    		checkCudaErrors(cudaMalloc((void **)&d_Histogram, HISTOGRAM256_BIN_COUNT * sizeof(uint)));
	    	checkCudaErrors(cudaMemcpy(d_Data, h_Data, byteCount, cudaMemcpyHostToDevice));	
            	histogram64(d_Histogram, d_Data, byteCount);
	    	cudaDeviceSynchronize();
		sdkStopTimer(&hTimer);
	        double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / 1.0;
        	//printf("histogram64() time (average) : %.5f sec, %.4f MB/sec\n\n", dAvgSecs, ((double)byteCount * 1.0e-6) / dAvgSecs);
        	printf("histogram64, Throughput = %.4f MB/s, Time = %.5f s, Size = %u Bytes, NumDevsUsed = %u, Workgroup = %u\n",
             		(1.0e-6 * (double)byteCount / dAvgSecs), dAvgSecs, byteCount, 1, HISTOGRAM64_THREADBLOCK_SIZE);

	        checkCudaErrors(cudaMemcpy(h_HistogramGPU, d_Histogram, HISTOGRAM64_BIN_COUNT * sizeof(uint), cudaMemcpyDeviceToHost));
        	byteCount = 10 * byteCount;
		checkCudaErrors(cudaFree(d_Histogram));
        	checkCudaErrors(cudaFree(d_Data));
	        free(h_HistogramGPU);
        	free(h_HistogramCPU);
	        free(h_Data);
	}
    }

   //printf("Shutting down...\n");
   sdkDeleteTimer(&hTimer);
   cudaDeviceReset();
   //printf("%s - Test Summary\n", sSDKsample);

    // pass or fail (for both 64 bit and 256 bit histograms)
   if (!PassFailFlag)
   {
       printf("Test failed!\n");
       exit(EXIT_FAILURE);
   }

   //printf("Test passed\n");
   exit(EXIT_SUCCESS);
}

