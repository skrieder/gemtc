__device__ void imageconvolution(void *param)
{

float *input = (float *) param;
int IW = (int)input[0];   //Image Width
int MW = (int)input[1]; //MASK_WIDTH;
float* image = input+2; 
float* mask = image + IW;
float* imageout = image + MW + IW;
int warp_size=32;
int threadId = threadIdx.x % warp_size;
float value =0;
int start;
int index;
printf("%d - %d \n", MW, IW);
//this function includes 2 floating point operations
while(threadId < IW)
{
start = threadId - (MW/2);
for(int i=0; i<MW;i++){
        index= start + i;
        if(index >=0 && index < IW)
                value = value + image[index] * mask[i];
}
threadId = threadId + warp_size;
imageout[threadId] = value;
printf("%d - %f \n", threadId, imageout[threadId]);
}
}

