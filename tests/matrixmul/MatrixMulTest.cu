#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

// flag == 0 Input, flag ==1 Output
void printStart(void *param,int flag){
  float *input = (float *) param;

  //    int MW = (int)*input;                                                                          

  int MW = (int)input[0];   //Matrix Width                                                             

 // printf("\n Matrix - width %d\n", MW);

  float* matrixA = input+1; // A pointer to where the input matrix starts 
  float* matrixB = matrixA + MW*MW;                             
  float* matrixOut = matrixA + 2*MW*MW;

  int i;
  if(flag ==0){
    printf("Printing Input\nMatrix A: \n");
   for(i=0; i<(MW*MW); i++){
      if (i%MW == 0 && i!=0)
        printf("\n");
    printf("%f ", matrixA[i]);
  }
        printf("\nMatrix B:\n");
  
  for(i=0; i<(MW*MW); i++){
      if (i%MW == 0 && i!=0)
        printf("\n");
    printf("%f ", matrixB[i]);
  }
 
 }
 if(flag ==1){
 printf("\nPrinting Output\n"); 
  for(i=0; i<(MW*MW); i++){
    if (i%MW == 0 && i!=0)
	   printf("\n");
  
  printf("%f ", matrixOut[i]);
   }
  }
  // Add some asserts here
  // print 'TRUE/SUCCESS'
}

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, MATRIX_SIZE,MATRIX_ELEMENT;

  if(argc>4){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);
    MATRIX_SIZE = atoi(argv[3]);
    MATRIX_ELEMENT = atoi(argv[4]);
    
  }else{
    printf("This test requires four parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int MATRIX_SIZE, int STATIC_VALUE\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    printf("       MATRIX_SIZE is the side length of the matrix\n");
    printf("       MATRIX_ELEMENT is the element to be used in the matrix\n");
    printf("       STATIC_VALUE is the integer value used as all elements in the matrix.\n");
    

    exit(1);
  }

  gemtcSetup(25600, 1);

  int size = sizeof(float)*(1+3*MATRIX_SIZE*MATRIX_SIZE);

  int j;
  float *h_params = (float *) malloc(size);
  h_params[0] = MATRIX_SIZE;
  for(j=1; j<2*MATRIX_SIZE*MATRIX_SIZE+1; j++){
    h_params[j]= MATRIX_ELEMENT; //((float) rand())/INT_MAX;
  }

  //0 for printing inputs 
  printStart(h_params,0);

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
      //printf("Value Returned\n");
      // Copy back the results
      gemtcMemcpyDeviceToHost(h_params, ret, size);

      // Free the device pointer
      gemtcGPUFree(ret);
      //      gemtcGPUFree(&d_params);

      // Do we need to do this?
      ret = NULL;
    }
  }
  // 1 for printing output
  printStart(h_params,1);
  gemtcCleanup();
  free(h_params);
  return 0;
}
