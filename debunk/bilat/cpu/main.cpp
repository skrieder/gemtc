#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <math.h>
//#define NUM_TEST 1
//#define TEST_RUN 4
//#include "common/error.h"


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

float gaussian1d(float x, float sigma)
{
        float variance = pow(sigma,2);
        float exponent = -pow(x,2)/(2*variance);
        return expf(exponent) / sqrt(2 * PI * variance);
}

float gaussian2d(float x, float y, float sigma)
{
        float variance = pow(sigma,2);
        float exponent = -(pow(x,2) + pow(y,2))/(2*variance);
        return expf(exponent) / (2 * PI * variance);
}



inline
RGB operator +(RGB a, RGB b) {
	RGB c;
	c.R = a.R + b.R;
	c.G = a.G + b.G;
	c.B = a.B + b.B;
	return c;
}

inline
RGB operator *(RGB a, RGB b) {
	RGB c;
	c.R = a.R * b.R;
	c.G = a.G * b.G;
	c.B = a.B * b.B;
	return c;
}

inline
RGB operator /(RGB a, RGB b) {
	RGB c;
	c.R = a.R / b.R;
	c.G = a.G / b.G;
	c.B = a.B / b.B;
	return c;
}

inline
RGB makeColor(float R,float G, float B) {
	RGB c;
	c.R = R;
	c.G = G;
	c.B = B;
	return c;
}


void CPUbilateralFiltering(RGB* data, int width, int height,int radius, float sigma_spatial, float sigma_range)
{
	int numElements = width*height;
	RGB* res_data = (RGB *)malloc (sizeof(RGB) * width * height);
	for(int x = 0; x < width; x++)
	{
		for(int y = 0; y < height; y++)
		{
			int array_idx = y * width + x;
			RGB currentColor = data[array_idx]; //idx

			RGB res = makeColor(0.0f,0.0f,0.0f);
			RGB normalization = makeColor(0.0f,0.0f,0.0f);


			for(int i = -radius; i <= radius; i++) {
				for(int j = -radius; j <= radius; j++) {
					int x_sample = x+i;
					int y_sample = y+j;

					//mirror edges
					if( (x_sample < 0) || (x_sample >= width ) ) {
						x_sample = x-i;
					}
			
					if( (y_sample < 0) || (y_sample >= height) ) {
						y_sample = y-j;
					}

					RGB tmpColor = data[y_sample * width + x_sample];

					float gauss_spatial = gaussian2d(i,j,sigma_spatial); //gaussian1d(i,sigma_spatial)*gaussian1d(j,sigma_spatial);//
					RGB gauss_range;
					gauss_range.R = gaussian1d(currentColor.R - tmpColor.R, sigma_range);
					gauss_range.G = gaussian1d(currentColor.G - tmpColor.G, sigma_range);
					gauss_range.B = gaussian1d(currentColor.B - tmpColor.B, sigma_range);
			
					RGB weight;
					weight.R = gauss_spatial * gauss_range.R;
					weight.G = gauss_spatial * gauss_range.G;
					weight.B = gauss_spatial * gauss_range.B;

					normalization = normalization + weight;

					res = res + (tmpColor * weight);

				}
			}
	
			res_data[array_idx] = res / normalization;
		}
	}

	for(int i = 0; i < numElements; i++)
	{
		data[i] = res_data[i];
	}
	free(res_data);

}


int main(int argc, char** argv) {
    if (argc != 3){
        printf("invalid parameters, use:  <WIDTH> <HEIGHT>\n");
    return -1;
    }

	const unsigned int channels = atoi(argv[1]);
        unsigned int width = atoi(argv[1]);
        unsigned int height = atoi(argv[2]);
        radius = 1;//atoi(argv[2]);
        sigma_spatial = 1.0;//(float)atof(argv[3]);
        sigma_range = 1.0; //(float)atof(argv[4]);
	srand (2009);
	struct timeval tim;
	double t1,t2;
	int NUM_TEST = 1;//1atoi(argv[2]);
        //for(int i = 0; i < TEST_RUN; i++)
        //{
        	RGB *data=(RGB *) malloc (sizeof(RGB) * width * height);
                for(int j = 0; j < (width * height); j++)
                	{
                                        RGB c;
                                        c.R = rand() % 255;
                                        c.G = rand() % 255;
                                        c.B =  rand() % 255;
                                        data[j] = c;
                        }


			gettimeofday(&tim, NULL);
			t1=tim.tv_sec+(tim.tv_usec/1000000.0);
                        for(int k = 0; k < NUM_TEST; k++)
                        {
                                CPUbilateralFiltering(data,width,height,radius,sigma_spatial,sigma_range);
                        }
                        gettimeofday(&tim, NULL);
			t2=tim.tv_sec+(tim.tv_usec/1000000.0);
                        double dAvgSecs = (t2-t1) / (double) NUM_TEST;
                        printf("%u\t%.5f\n",width*height, dAvgSecs);
                        free(data);

                        width *= 2;
          //      }

    return EXIT_SUCCESS;
}

