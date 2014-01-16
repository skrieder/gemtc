#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

void printStart(void *param){

  float *input = (float *) param;

  //    int MW = (int)*input;                                                                          

  int MW = (int)input[0];   //Matrix Width                                                             

  printf("\n Matrix - width %d\n", MW);

  float* matrix = input+1; // A pointer to where the input matrix starts                               
  float* matrixOut = matrix + 2*MW*MW;

  int i;
  for(i=0; i<(MW*MW); i++){
    if (i%MW == 0 && i!=0)
	printf("\n");
    printf("%f ", matrix[i]);
  }
 printf("\nPrinting Matrix out\n");
  for(i=0; i<(MW*MW); i++){
    if (i%MW == 0 && i!=0)
	   printf("\n");
  
  printf("%f ", matrixOut[i]);
  }
  // Add some asserts here
  // print 'TRUE/SUCCESS'
}

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, MATRIX_SIZE;

  if(argc>3){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);
    MATRIX_SIZE = atoi(argv[3]);
  }else{
    printf("This test requires three parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int MATRIX_SIZE\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    printf("       MATRIX_SIZE is the side length of the matrix that is going to be squared\n");
    exit(1);
  }

  gemtcSetup(25600, 1);

  int size = sizeof(float)*(1+3*MATRIX_SIZE*MATRIX_SIZE);

  int j;
  float *h_params = (float *) malloc(size);
  h_params[0] = MATRIX_SIZE;
  for(j=1; j<2*MATRIX_SIZE*MATRIX_SIZE+1; j++){
    h_params[j]= 2; //((float) rand())/INT_MAX;
  }

  // 
  printStart(h_params);

  for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
    int i;
    for(i=0; i<LOOP_SIZE; i++){
      float *d_params = (float *) gemtcGPUMalloc(size);

      gemtcMemcpyHostToDevice(d_params, h_params, size);
      gemtcPush(5, 32, i+j*LOOP_SIZE, d_params);
    }

    for(i=0; i<LOOP_SIZE; i++){
      void *ret=NULL;
      int id;
      while(ret==NULL){
	//        printf("Calling GeMTC Poll...");
	gemtcPoll(&id, &ret);
	//printf("complete.\n");
	
      }
      printf("Value Returned\n");
      // Copy back the results
      gemtcMemcpyDeviceToHost(h_params, ret, size);

      // Free the device pointer
      gemtcGPUFree(ret);
      //      gemtcGPUFree(&d_params);

      // Do we need to do this?
      ret = NULL;
    }
  }
  printStart(h_params);
  gemtcCleanup();
  free(h_params);
  return 0;
}
