#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){

  int NUM_TASKS, SORT_SIZE;

  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    SORT_SIZE = atoi(argv[2]);
  }else{
    printf("This test requires two parameters:\n");
    printf("   int NUM_TASKS, SORT_SIZE\n");
    printf("where  NUM_TASKS is the total numer of tasks to be run, must be a multiple of 100\n");
    printf("       SORT_SIZE is the size of the array that sort will be called on in each task\n");
    exit(1);
  }

  gemtcSetup(25600, 1);

  int LOOP_SIZE=1;

  //We will Push LOOP_SIZE tasks
  // Then Poll until we have LOOP_SIZE results
  // Until we have run all the tasks
  float *h_sort = (float *)malloc(sizeof(float)*(1 + 2*SORT_SIZE));


  //Randomly fill h_sort with floats
  //This currently will only generate random values once and use these for all tests.
  //This makes sure the test is only measuring GPU times, because this single cost should
  //  be washed out by the many sorts
  *h_sort = (float) SORT_SIZE;
  int k;
  for(k=0;k<SORT_SIZE;k++){
    h_sort[k+1] = (float)rand()/(float)RAND_MAX;  //random float 0.0-1.0
    printf("in[%d]   :   %f\n",k, h_sort[k+1]);
  }

  int j;
  for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
    int i;
    for(i=0; i<LOOP_SIZE; i++){
      //Sort requires memory setup like:
      //    | int size |    float  ary[1..size]    |    float  ret[1..size]    |
      //
      //This currently changes ary and makes the final sorted result in ret

      float *d_sort = (float *) gemtcGPUMalloc(sizeof(float)*(SORT_SIZE*2 + 1));

      gemtcMemcpyHostToDevice(d_sort, h_sort, sizeof(float)*(1+SORT_SIZE));
      gemtcPush(3, 32, i+j*LOOP_SIZE, d_sort);
    }

    for(i=0; i<LOOP_SIZE; i++){
      void *ret = NULL;
      int id;
      while(ret==NULL){
        gemtcPoll(&id, &ret);
      }

      //      gemtcMemcpyDeviceToHost(h_sort + sizeof(float)*(1+SORT_SIZE), ((float *)ret) + sizeof(float)*(1+SORT_SIZE), sizeof(float)*SORT_SIZE);
      gemtcMemcpyDeviceToHost(h_sort + 1, ((float *)ret) + 1, sizeof(float)*SORT_SIZE);

      //Print final
      int k;
      for(k=0;k<SORT_SIZE;k++){
        printf("ret[%d]  :  %f\n",k, h_sort[1+k]);
      }
      gemtcGPUFree(ret);
      ret = NULL;
    }
  }
  free(h_sort);
  gemtcCleanup();

  return 0;
}
