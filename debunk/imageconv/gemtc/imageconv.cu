#include "../../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>

//#define DEBUG 1
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

int main(int argc, char **argv){
  int NUM_TASKS, IMAGE_WIDTH, MASK_WIDTH;
  int warps;
  int Overfill = 0;
  cudaDeviceProp devProp;
  cudaGetDeviceProperties(&devProp, 0);
  int blocks = devProp.multiProcessorCount;
  if(argc>2){

    IMAGE_WIDTH = atoi(argv[1]);
    MASK_WIDTH = atoi(argv[2]);

  }else{
    printf("This test requires four parameters:\n");
    printf("   int IMAGE_WIDTH, int MSAK_WIDTH\n");
    printf("       IMAGE_WIDTH is the number of pixels in an image in one dimensional\n");
    printf("       MASK_WIDTH is the width of the mask to be applied on the image\n");


    exit(1);
  }
  
  if(Overfill==1){
    warps = devProp.maxThreadsPerBlock/32;
  }
	if(Overfill==0){
		int coresPerSM = _ConvertSMVer2Cores(devProp.major, devProp.minor);
		warps = coresPerSM/16;  //A warp runs on 16 cores
	}
	if(Overfill==2){
		warps =1;
		blocks = 1;
	}
	NUM_TASKS = warps * blocks;
	IMAGE_WIDTH = IMAGE_WIDTH/NUM_TASKS;

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
  #ifdef DEBUG
  printStart(h_params,0);
  #endif
  //Starting timing
  struct timeval tim;
  double t1,t2;
  gettimeofday(&tim, NULL);
  t1=tim.tv_sec+(tim.tv_usec/1000000.0);
  for(j=0; j<NUM_TASKS; j++){
	  float *d_params = (float *) gemtcGPUMalloc(size);

	  gemtcMemcpyHostToDevice(d_params, h_params, size);
	  gemtcPush(32, 32, j, d_params);
   
    }
	
	  void *ret=NULL;
	  int id;
	  while(ret==NULL){
		gemtcPoll(&id, &ret);
	  }

     gemtcMemcpyDeviceToHost(h_params, ret, size);
     gettimeofday(&tim, NULL);
     t2=tim.tv_sec+(tim.tv_usec/1000000.0);
      // Free the device pointer
     gemtcGPUFree(ret);
    

      // Do we need to do this?
      ret = NULL;

  // 1 for printing output
  #ifdef DEBUG
  printStart(h_params,1);
  #endif
  printf("%.4lf\t", (t2-t1));
  gemtcCleanup();
  free(h_params);
  return 0;
}
