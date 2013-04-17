#include <stdio.h>
#include <stdlib.h>
//#include "gemtc_types.h"
#include "gemtc_mic_api.h"

int main(int argv, char **argc) {
  int workers=1;
  int numTasks=1;  //Must be multiple of loopSize (currently 100)
  long sleepTime=1;

  //Get these values from argc, if given
  if(argv>3){
    workers = atoi(argc[1]);
    numTasks = atoi(argc[2]);
    sleepTime = atol(argc[3]);
  }
  printf("Recieved parameters\n");

  int loopSize = 1;//Must be less than QueueSize (currently 1000)

  MIC_gemtcSetup(1000, workers); //1000==QueueSize

  printf("Setup Done\n");

  int i, j;
  for(i=0;i<numTasks;){
    printf("Starting to send batch\n");
    for(j=0;j<loopSize;j++){
      MIC_gemtcPush(0,1,i,&sleepTime);
      i++;
    }
    printf("batch sent, starting to recieve\n");
    for(j=0;j<loopSize;j++){
      // (int *ID, void **params) 
      int result_id = -1;
      void *result_params;

      while(result_id == -1) { MIC_gemtcPoll(&result_id, &result_params); }

      printf("JOB: %d, result: %d", result_id, *(int*)result_params);
      free(result_params);
    }
    printf("batch received\n");
  }
  MIC_gemtcCleanup();
  printf("Cleanup done\n");
  return 0;
}