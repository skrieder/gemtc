// CUDA Runtime
#include <cuda_runtime.h>

// Utility and system includes
#include "helper_cuda.h"
#include "helper_functions.h"  // helper for shared that are common to CUDA SDK samples

// project include
#include "histogram_common.h"

const int numRuns = 6;

int main(int argc, char **argv)
{
    uchar *h_Data;
    uint  *h_HistogramGPU;
    uchar *d_Data;
    uint  *d_Histogram;
    StopWatchInterface *hTimer = NULL;
    int PassFailFlag = 1;
    uint byteCount = 1024;
    uint uiSizeMult = 1;

    cudaDeviceProp deviceProp;
    deviceProp.major = 0;
    deviceProp.minor = 0;

    //Use command-line specified CUDA device, otherwise use device with highest Gflops/s
    int dev = findCudaDevice(argc, (const char **)argv);

    checkCudaErrors(cudaGetDeviceProperties(&deviceProp, dev));

    int version = deviceProp.major * 0x10 + deviceProp.minor;

    if (version < 0x11)
    {
        printf("There is no device supporting a minimum of CUDA compute capability 1.1 for this SDK sample\n");
        cudaDeviceReset();
        exit(EXIT_SUCCESS);
    }

   sdkCreateTimer(&hTimer);

    {
        for (int iter = 0; iter < numRuns; iter++)
        {
        	initHistogram256();
		
		sdkResetTimer(&hTimer);
	        sdkStartTimer(&hTimer);
    		h_Data         = (uchar *)malloc(byteCount);
    		h_HistogramGPU = (uint *)malloc(HISTOGRAM256_BIN_COUNT * sizeof(uint));

    		srand(2009);

	   	 for (uint i = 0; i < byteCount; i++)
    		{
        		h_Data[i] = rand() % 256;
	    	}	

	    	checkCudaErrors(cudaMalloc((void **)&d_Data, byteCount));
    		checkCudaErrors(cudaMalloc((void **)&d_Histogram, HISTOGRAM256_BIN_COUNT * sizeof(uint)));
	    	checkCudaErrors(cudaMemcpy(d_Data, h_Data, byteCount, cudaMemcpyHostToDevice));	
            	histogram256(d_Histogram, d_Data, byteCount);
	    	cudaDeviceSynchronize();
		sdkStopTimer(&hTimer);
	        double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / 1.0;
        	printf("Throughput = %.4f MB/s, Time = %.5f s, Size = %u Bytes, NumDevsUsed = %u, Workgroup = %u\n",
             		(1.0e-6 * (double)byteCount / dAvgSecs), dAvgSecs, byteCount, 1, HISTOGRAM256_THREADBLOCK_SIZE);

	        checkCudaErrors(cudaMemcpy(h_HistogramGPU, d_Histogram, HISTOGRAM256_BIN_COUNT * sizeof(uint), cudaMemcpyDeviceToHost));
        	byteCount = 10 * byteCount;
		checkCudaErrors(cudaFree(d_Histogram));
        	checkCudaErrors(cudaFree(d_Data));
	        free(h_HistogramGPU);
	        free(h_Data);
		closeHistogram256();
	}
    }

   sdkDeleteTimer(&hTimer);
   cudaDeviceReset();
   exit(EXIT_SUCCESS);
}

