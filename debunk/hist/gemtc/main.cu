#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include "histogram_common.h"

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

  gemtcSetup(25600, 1);

  int d_size = sizeof(uint)*(byteCount);
  int p_size = PARTIAL_HISTOGRAM256_COUNT * HISTOGRAM256_BIN_COUNT * sizeof(uint);
  int h_size =HISTOGRAM256_BIN_COUNT * sizeof(uint);
  int size = 1 + d_size + p_size + h_size;
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
                printf("Inside Inner Loop /n");
		
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
  printf("Completed\n");
  return 0;
}
