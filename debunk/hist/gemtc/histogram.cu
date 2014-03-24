#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#define BIN_COUNT 256
#define NUM_RUNS 6
#include <helper_functions.h>

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE;
  uint byteCount = 1024;
  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);

  }else{
    printf("This test requires four parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int MATRIX_SIZE, int STATIC_VALUE\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    exit(1);
  }
  StopWatchInterface *hTimer = NULL; 
  int iter;
   sdkCreateTimer(&hTimer);   
  for(iter=0; iter < NUM_RUNS; iter++) {
  sdkResetTimer(&hTimer);
  sdkStartTimer(&hTimer); 
  gemtcSetup(25600, 1);

  int d_size = sizeof(unsigned int) * byteCount;
  int h_size = sizeof(int) * BIN_COUNT;
  int size = 1 + d_size + h_size;
  int j;
  uint *h_params = (uint *) malloc(size);

   srand(2009);
   h_params[0] = byteCount;
   for (uint i = 1; i <= byteCount; i++)
   {
        h_params[i] = rand() % 256;
   }

   for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
        int i;
        for(i=0; i<LOOP_SIZE; i++){
                uint *d_params = (uint *) gemtcGPUMalloc(size);
                gemtcMemcpyHostToDevice(d_params, h_params, size);
                gemtcPush(34, 32, i+j*LOOP_SIZE, d_params);

        }

        for(i=0; i<LOOP_SIZE; i++){
                void *ret=NULL;
                int id;
                while(ret==NULL){
                gemtcPoll(&id, &ret);
                }
      // Copy back the results
                gemtcMemcpyDeviceToHost(h_params, ret, size);

      // Free the device pointer
                gemtcGPUFree(ret);
        }
  }
  gemtcCleanup();
  free(h_params);
  sdkStopTimer(&hTimer);

  double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / 1.0;
  printf("Throughput = %.4f MB/s, Time = %.5f s, Size = %u Bytes\n",
                        (1.0e-6 * (double)byteCount / dAvgSecs), dAvgSecs, byteCount);
  byteCount *= 10;
  }
  printf("Completed\n");
  sdkDeleteTimer(&hTimer);
  return 0;
}

