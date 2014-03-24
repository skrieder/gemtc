#include <cuda_runtime.h>

// Utility and system includes
#include <helper_cuda.h>
#include <helper_functions.h>  // helper for shared that are common to CUDA SDK samples

// project include
#include "histogram_common.h"

const int numRuns = 1;
static char *sSDKsample = "[histogram]\0";

void printOutput(int byteCount, uint *histogram)
{
	int i;
	for(i=0;i< byteCount; i++){
		printf("%d \t", histogram[i]);
	}
}

int main(int argc, char **argv)
{
    uchar *h_Data;
    uint  *h_HistogramGPU;
    uchar *d_Data;
    uint  *d_Histogram;
    StopWatchInterface *hTimer = NULL;
    int PassFailFlag = 1;
    uint byteCount = 64;
    uint uiSizeMult = 1;

    cudaDeviceProp deviceProp;
    deviceProp.major = 0;
    deviceProp.minor = 0;

     //Use command-line specified CUDA device, otherwise use device with highest Gflops/s
    int dev = findCudaDevice(argc, (const char **)argv);

    checkCudaErrors(cudaGetDeviceProperties(&deviceProp, dev));

    printf("CUDA device [%s] has %d Multi-Processors, Compute %d.%d\n",
           deviceProp.name, deviceProp.multiProcessorCount, deviceProp.major, deviceProp.minor);

    int version = deviceProp.major * 0x10 + deviceProp.minor;

    if (version < 0x11)
    {
        printf("There is no device supporting a minimum of CUDA compute capability 1.1 for this SDK sample\n");
        cudaDeviceReset();
        exit(EXIT_SUCCESS);
    }

    sdkCreateTimer(&hTimer);

    // Optional Command-line multiplier to increase size of array to histogram
    if (checkCmdLineFlag(argc, (const char **)argv, "sizemult"))
    {
        uiSizeMult = getCmdLineArgumentInt(argc, (const char **)argv, "sizemult");
        uiSizeMult = MAX(1,MIN(uiSizeMult, 10));
        byteCount *= uiSizeMult;
    }

    printf("Initializing data...\n");
    printf("...allocating CPU memory.\n");
    h_Data         = (uchar *)malloc(byteCount);
    h_HistogramGPU = (uint *)malloc(HISTOGRAM256_BIN_COUNT * sizeof(uint));

    printf("...generating input data\n");
    srand(2009);

    for (uint i = 0; i < byteCount; i++)
    {
        h_Data[i] = rand() % 256;
    }

    printf("...allocating GPU memory and copying input data\n\n");
    checkCudaErrors(cudaMalloc((void **)&d_Data, byteCount));
    checkCudaErrors(cudaMalloc((void **)&d_Histogram, HISTOGRAM256_BIN_COUNT * sizeof(uint)));
    checkCudaErrors(cudaMemcpy(d_Data, h_Data, byteCount, cudaMemcpyHostToDevice));

     {
        printf("Initializing 256-bin histogram...\n");
        initHistogram256();

        printf("Running 256-bin GPU histogram for %u bytes (%u runs)...\n\n", byteCount, numRuns);

        for (int iter = -1; iter < numRuns; iter++)
        {
            //iter == -1 -- warmup iteration
            if (iter == 0)
            {
                checkCudaErrors(cudaDeviceSynchronize());
                sdkResetTimer(&hTimer);
                sdkStartTimer(&hTimer);
            }

            histogram256(d_Histogram, d_Data, byteCount);
        }

        cudaDeviceSynchronize();
        sdkStopTimer(&hTimer);
        double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / (double)numRuns;
        printf("histogram256() time (average) : %.5f sec, %.4f MB/sec\n\n", dAvgSecs, ((double)byteCount * 1.0e-6) / dAvgSecs);
        printf("histogram256, Throughput = %.4f MB/s, Time = %.5f s, Size = %u Bytes, NumDevsUsed = %u, Workgroup = %u\n",
               (1.0e-6 * (double)byteCount / dAvgSecs), dAvgSecs, byteCount, 1, HISTOGRAM256_THREADBLOCK_SIZE);

        printf("\nValidating GPU results...\n");
        printf(" ...reading back GPU results\n");
        checkCudaErrors(cudaMemcpy(h_HistogramGPU, d_Histogram, HISTOGRAM256_BIN_COUNT * sizeof(uint), cudaMemcpyDeviceToHost));
	printOutput(byteCount, h_HistogramGPU);
        printf("Shutting down 256-bin histogram...\n\n\n");
        closeHistogram256();
    }

    sdkDeleteTimer(&hTimer);
    checkCudaErrors(cudaFree(d_Histogram));
    checkCudaErrors(cudaFree(d_Data));
    free(h_HistogramGPU);
    free(h_Data);

    cudaDeviceReset();
    exit(EXIT_SUCCESS);
}

