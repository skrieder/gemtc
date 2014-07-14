#include <stdio.h>
#include <stdlib.h>
//#include "CPUgemtcOpenMP.h"
#include "Queue.h"

int kill;

int main(int argv, char **argc) {

   int numthreads = 1;
   int numTasks = 1;  //Must be multiple of loopSize (currently 100)
   long sleepTime = 1;
   
   //Get these values from argc, if given
   if(argv>3){
      numthreads = atoi(argc[1]);
      numTasks = atoi(argc[2]);
      sleepTime = atol(argc[3]);
   }
   printf("Received parameters\n");

   int loopSize = 1;//Must be less than QueueSize (currently 1000)
   
   omp_set_num_threads(numthreads);
   
   #pragma omp parallel
   {
      #pragma omp single nowait
      {
      CPU_gemtcSetup(1000, numthreads); //1000==QueueSize
      }

      printf("Setup Done\n");

      int i, j;
      #pragma omp for nowait
      for(i=0;i<numTasks;i++){
	 printf("Starting to send batch\n");
	 for(j=0;j<loopSize;j++){
	    CPU_gemtcPush(2,1,i,&sleepTime);
	    i++;
	 }
	 printf("batch sent, starting to receive\n");
	 for(j=0;j<loopSize;j++){
	    JobPointer task;
	    do {
	       task = CPU_gemtcPoll();
	    }
	    while(task == NULL);
	    printf("Result from %d\n", task->JobID);
	    free(task);
	 }
	 printf("batch received\n");
      }
   }
printf("VOU LIMPAAAARRR\n");
   CPU_gemtcCleanup();
   printf("Cleanup done\n");
   return 0;
}