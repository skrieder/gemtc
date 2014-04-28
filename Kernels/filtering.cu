#include <math.h>
#include "../debunk/bilat/helper/uint_util.hcu"
#include "../debunk/bilat/helper/float_util.hcu"
#define PI 3.14159265

__device__
float gaussian1d(float x, float sigma)
{
        float variance = pow(sigma,2);
        float exponent = -pow(x,2)/(2*variance);
        return expf(exponent) / sqrt(2 * PI * variance);
}

__device__
float gaussian2d(float x, float y, float sigma)
{
        float variance = pow(sigma,2);
        float exponent = -(pow(x,2) + pow(y,2))/(2*variance);
        return expf(exponent) / (2 * PI * variance);
}
__device__
void bilateralFilter(void *inp)
{
        unsigned int idx = threadIdx.x % 32;
	float3* input;
	float3* output;
	uint2 dims;
        float3 *in = (float3 *)inp;
        float3 first = in[0];
	float3 second =in[1];
        float3 third = in[2];

        int size = first.x;
	int width = first.y;
	int height = first.z;
	dims = make_uint2(width,height);
	//unsigned int channel = second.x;
	unsigned int radius = second.y;
	float sigma_spatial = second.z;
	float sigma_range = third.x;

	input = in + 3;
	output = input + size;
	while(idx < size) {
//	printf("Thread : %d\n",idx);
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
	idx +=32;
	}
}
