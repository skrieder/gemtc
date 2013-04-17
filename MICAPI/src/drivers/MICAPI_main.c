#include <stdio.h>
#include <stdlib.h>
//#include "gemtc_types.h"
#include "gemtc_mic_api.h"

int main(int argv, char **argc) {
  int workers=1;
  int numTasks=1;  //Must be multiple of loopSize (currently 100)
  long sleepTime=1;
  int batches=1;
  int queueSize = 1000;

  //Get these values from argc, if given
  if(argv>3){
    workers = atoi(argc[1]);
    numTasks = atoi(argc[2]);
    sleepTime = atol(argc[3]);
    batches = atoi(argc[4]);
  }

  if (batches > queueSize) {
    printf("Error, batch size can not be larger than queue size of: %d\n", queueSize);
    return -1;
  }

  printf("== GEMTC_MIC Initalizing ===========\n");
  printf("+ Workers: %d\n", workers);
  printf("+ numTasks/batch: %d\n", numTasks);
  printf("+ sleepTime: %ld\n", sleepTime);
  printf("+ batches: %d\n", batches);

  printf(" -> To change: %s [workers] [numTasks/batch] [sleepTime] [batches]\n", argc[0]);

  MIC_gemtcSetup(queueSize, workers); //1000==QueueSize

  printf("== GEMTC_MIC Initalized ===========\n\n");

  int i, j;
  for(i=0;i<batches;i++){
    printf("- Sending Batch ---------------\n");
    for(j=0;j<numTasks;j++){
      MIC_gemtcPush(0,1,i * batches + j,&sleepTime);
      printf(".");
      if (j % 10 == 1) { printf("\n"); }
    }
    printf("\n- Batch Sent ------------------\n");
    printf("- Reciving Batch ---------------\n");
    for(j=0;j<numTasks;j++){

      int result_id = -1;
      void *result_params;

      while(result_id == -1) { MIC_gemtcPoll(&result_id, &result_params); }

      printf("+ Job: %d, result: %d\n", result_id, *(int*)result_params);
 
    }
    printf("= All Jobs Recieved\n");
  }
  printf("== GEMTC_MIC Deinitalizing ===========\n");
  MIC_gemtcCleanup();
  printf("== GEMTC_MIC Deinitalized ============\n");
  return 0;
}