#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

// flag == 0 Input, flag ==1 Output
void printStart(void *param,int flag){
  float *input = (float *) param;
  int IW = (int)input[0];   //Image Width
  int MW = (int)input[1]; //MASK_WIDTH;
  float* image = input+2; 
  float* mask = image + IW;
  float* imageout = image + MW + IW;

  int i;
  if(flag ==0){
    printf("Printing Image: \n");
   for(i=0; i<IW; i++){
      if (i%IW == 0 && i!=0)
        printf("\n");
    printf("%f ", image[i]);
  }
	printf("\nPrinting Mask: \n");

  for(i=0; i<MW; i++){
      if (i%MW == 0 && i!=0)
        printf("\n");
   printf("%f", mask[i]);
  }
 }
 if(flag ==1){
 printf("\nPrinting Output\n");
  for(i=0; i<IW; i++){
    if (i%IW == 0 && i!=0)
           printf("\n");

  printf("%f ", imageout[i]);
   }
  }
}

void populateRandomFloatArray(int n, float *x){
  
}
int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, IMAGE_WIDTH, MASK_WIDTH;

  if(argc>4){
    NUM_TASKS = atoi(argv[1]);
    LOOP_SIZE = atoi(argv[2]);
    IMAGE_WIDTH = atoi(argv[3]);
    MASK_WIDTH = atoi(argv[4]);

  }else{
    printf("This test requires four parameters:\n");
    printf("   int NUM_TASKS, int LOOP_SIZE, int IMAGE_WIDTH, int MSAK_WIDTH\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       LOOP_SIZE is the number of tasks should be sent to gemtc before waiting for results\n");
    printf("	   IMAGE_WIDTH is the number of pixels in an image in one dimensional\n");
    printf("       MASK_WIDTH is the width of the mask to be applied on the image\n");


    exit(1);
  }

  gemtcSetup(25600, 1);

  int size = sizeof(float)*(2+2 * IMAGE_WIDTH + MASK_WIDTH);

  int j;
  int temp_size = IMAGE_WIDTH + MASK_WIDTH;
  float *h_params = (float *) malloc(size);
  h_params[0] = IMAGE_WIDTH;
  h_params[1] = MASK_WIDTH;
  
  for(j=2; j<temp_size+2; j++){
    float r = (float)(rand() % 100);
    h_params[j] = r;
  }
  //0 for printing inputs
  printStart(h_params,0);

  for(j=0; j<NUM_TASKS/LOOP_SIZE; j++){
    int i;
    for(i=0; i<LOOP_SIZE; i++){
      float *d_params = (float *) gemtcGPUMalloc(size);

      gemtcMemcpyHostToDevice(d_params, h_params, size);
      gemtcPush(32, 32, i+j*LOOP_SIZE, d_params);
    }

    for(i=0; i<LOOP_SIZE; i++){
      void *ret=NULL;
      int id;
      while(ret==NULL){
		gemtcPoll(&id, &ret);
      }
     
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
