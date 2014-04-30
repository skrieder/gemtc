#include <stdlib.h>
#include <stdio.h>
#include <device_launch_parameters.h>
#include <cuda_runtime.h>
#include <helper_cuda.h>
#include <helper_functions.h>
#include "../helper/uint_util.hcu"
#include "../helper/float_util.hcu"
//#include "common/error.h"

#include <math.h>

#define PI 3.14159265
#define IMAGE_SIZE 1024

#define CHECK_ERR(x)                                    \
  if (x != cudaSuccess) {                               \
    fprintf(stderr,"%s in %s at line %d\n",             \
            cudaGetErrorString(err),__FILE__,__LINE__); \
    exit(-1);                                           \
  }


unsigned int radius;
float sigma_spatial;
float sigma_range;
typedef struct {
        float R;
        float G;
        float B;

} RGB;

__host__ __device__
float gaussian1d(float x, float sigma)
{
        float variance = pow(sigma,2);
        float exponent = -pow(x,2)/(2*variance);
        return expf(exponent) / sqrt(2 * PI * variance);
}

__host__ __device__
float gaussian2d(float x, float y, float sigma)
{
        float variance = pow(sigma,2);
        float exponent = -(pow(x,2) + pow(y,2))/(2*variance);
        return expf(exponent) / (2 * PI * variance);
}
__global__
void bilateralFilterGPU_v1(float3* input, float3* output, uint2 dims, int radius, float sigma_spatial, float sigma_range)
{
        const unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;

        uint2 pos = idx_to_co(idx,dims);
        int img_x = pos.x;
        int img_y = pos.y;

        if(img_x >= dims.x || img_y >= dims.y) return;

        float3 currentColor = input[idx];

        float3 res = make_float3(0.0f,0.0f,0.0f);
        float3 normalization = make_float3(0.0f,0.0f,0.0f);;


        for(int i = -radius; i <= radius; i++) {
                for(int j = -radius; j <= radius; j++) {
                        int x_sample = img_x+i;
                        int y_sample = img_y+j;

                        //mirror edges
                        if( x_sample < 0) x_sample = -x_sample;
                        if( y_sample < 0) y_sample = -y_sample;
                        if( x_sample > dims.x - 1) x_sample = dims.x - 1 - i;
                        if( y_sample > dims.y - 1) y_sample = dims.y - 1 - j;


                        float3 tmpColor = input[co_to_idx(make_uint2(x_sample,y_sample),dims)];

                        float gauss_spatial = gaussian2d(i,j,sigma_spatial);
                        float3 gauss_range;
                        gauss_range.x = gaussian1d(currentColor.x - tmpColor.x, sigma_range);
                        gauss_range.y = gaussian1d(currentColor.y - tmpColor.y, sigma_range);
                        gauss_range.z = gaussian1d(currentColor.z - tmpColor.z, sigma_range);

                        float3 weight = gauss_spatial * gauss_range;
                        normalization = normalization + weight;
                        res = res + (tmpColor * weight);

                }
        }

        res.x /= normalization.x;
        res.y /= normalization.y;
        res.z /= normalization.z;
        output[idx] = res;
}

void bilateralFiltering_v1(RGB* data, int width, int height ,int radius, float sigma_spatial, float sigma_range) {
    unsigned int numElements = width * height;
    cudaError_t err;
    // copy data to device
    float3* d_data;
    err= cudaMalloc( (void**) &d_data, numElements*sizeof(RGB));
    CHECK_ERR(err);
    err= cudaMemcpy( d_data, data, numElements*sizeof(RGB), cudaMemcpyHostToDevice );
    CHECK_ERR(err);

        //Output image
    float3* d_result;
    err= cudaMalloc( (void**) &d_result, numElements*sizeof(RGB));
    CHECK_ERR(err);

    // setup dimensions of grid/blocks.
    dim3 blockDim(512,1,1);
    dim3 gridDim((unsigned int) ceil((double)(numElements/blockDim.x)), 1, 1 );

    // invoke kernel
        bilateralFilterGPU_v1<<< gridDim, blockDim >>>( d_data, d_result, make_uint2(width,height), radius, sigma_spatial, sigma_range);

    // copy data to host
    err= cudaMemcpy( data, d_result, numElements*sizeof(RGB), cudaMemcpyDeviceToHost );
    CHECK_ERR(err);
        cudaFree(d_data);
        cudaFree(d_result);

}

/*(RGB*) populateRGB(int width, int height){
int i=0;
int j=0;
srand (time(NULL));
RGB* colors = (RGB *) malloc (sizeof(RGB) * width * height);
for(int i = 0; i < numElements; i++)
        {
                RGB c;
                c.R = rand() % 255;
                c.G = rand() % 255;
                c.B =  rand() % 255;
                colors[i] = c;
        }
return colors;
}
*/
int main(int argc, char** argv) {
    if (argc != 3){
        printf("invalid parameters, use: <NUM_INPUTS> <NUM_TEST>\n");
    return -1;
    }
    
        //const unsigned int channels = 1;//atoi(argv[1]);
	StopWatchInterface *hTimer = NULL;
	unsigned int width = IMAGE_SIZE;
	unsigned int height = IMAGE_SIZE;
	sdkCreateTimer(&hTimer);
        radius = 1;//atoi(argv[2]);
        sigma_spatial = 1.0; //(float)atof(argv[3]);
        sigma_range = 1.0; //(float)atof(argv[4]);
	int TEST_RUN = atoi(argv[1]);
	int NUM_TEST = atoi(argv[2]);
        for(int i = 0; i < TEST_RUN; i++)
        {
			RGB *data=(RGB *) malloc (sizeof(RGB) * width * height);
			for(int j = 0; j < (width * height); j++)
			{
					RGB c;
					c.R = rand() % 255;
					c.G = rand() % 255;
					c.B =  rand() % 255;
					data[j] = c;
			}
			
			
			sdkResetTimer(&hTimer);
			sdkStartTimer(&hTimer);
			for(int k = 0; k < NUM_TEST; k++)
			{
				bilateralFiltering_v1(data,width,height,radius,sigma_spatial,sigma_range);
			}
			sdkStopTimer(&hTimer);
			double dAvgSecs = 1.0e-3 * (double)sdkGetTimerValue(&hTimer) / (double) NUM_TEST;
			printf("%u\t%.5f\n",width*height, dAvgSecs);
			free(data);
			
			width *= 2;
		}
		
	sdkDeleteTimer(&hTimer);
    return EXIT_SUCCESS;
}

