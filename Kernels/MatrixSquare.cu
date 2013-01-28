#include <stdio.h>

/*
__device__ void MatrixSquare(void *param)
{ 
    float *input = (float *) param;
    int warp_size=32;
    int matrixWidth = (int)input[0];
    float* matrix = input+1;
    float* matrixOut = matrix + matrixWidth*matrixWidth;
    //printf("%d\n", matrixWidth);
#if 1 
    int thread = threadIdx.x % warp_size;
        
    for (unsigned int i = thread; i < matrixWidth; i=i+32)
    {
      for (unsigned int j = 0; j < matrixWidth; j++) {
         float sum = 0;
         for (unsigned int k = 0; k < matrixWidth; k++) {
           float a = matrix[i * matrixWidth + k];
           float b = matrix[k * matrixWidth + j];
           sum += a * b;
         }
         //matrixOut[i * matrixWidth + j + (matrixWidth * matrixWidth)] = sum;
         matrixOut[i * matrixWidth + j ] = sum;
      }
   }
#endif
}
*/

__device__ void MatrixSquare(void *param)
{ 
  /*
BS = Block_Side

Matrix broken in sub blocks of size BSxBS,
a and b are used to number these large blocks:

         (a,b)=(BS,0)
     ___x___________
    |   |   |   |   |
    |___|___|___|___|
    |   |   |   |   |
    |___|___|___|___|
    |   |   |   |   |
    |___|___|___|___|
    |   |   |   |   |
    |___|___|___|___|


Within a block of BSxBS, thread i will process the elements at loc[k][i] for k:0..31
   */


    float *input = (float *) param;


    int MW = (int)input[0];   //Matrix Width
    float* matrix = input+1;
    float* matrixOut = matrix + MW*MW;
#if 1 
    int WarpSize = 32;
    int BS = 8;  //Block Side length, If changed, fix the size of values array below;

    int ID = gemtcThreadID();
    int IDx = ID%BS;
    int IDy = ID/BS;
    int numY = WarpSize/BS;  //If BS is 8, then numY is 4, because there is row 0,1,2 and 3
    int ElePerThr = BS*BS/WarpSize; //Elements per block to be processed by each thread

    float values[2];  //Used to be ElePerThr but needs to have constant
    for(int c=0;c<ElePerThr;c++){
      values[c]=0;
    }

    float *shared1 = (float *) gemtcSharedMemory();
    float *shared2 = shared1 + sizeof(float)*BS*BS;

    int astep = BS;
    int bstep = BS*MW;

    for (unsigned int a = 0; a<MW; a+=astep)
    {
      for (unsigned int b = 0; b<MW*MW; b+=bstep) {
        //find values for all elements in this block of matrix

	for(int k=0;k<MW/BS;k++){
	  //Walk row/column of current block
	  
	  for(int c=0;c<ElePerThr;c++){
	    //fill caches
	    shared1[IDx+IDy*BS+WarpSize*c] = matrix[a+IDx+(IDy+c*numY+k*BS)*MW];
	    shared2[IDx+IDy*BS+WarpSize*c] = matrix[b+k*BS+IDx+(IDy+c*numY)*MW];
	  }

	  for(int c=0;c<ElePerThr;c++){
	    //update running values for result
	    for(int i=0;i<BS;i++){
	      values[c]+= shared1[IDx+i*BS]*shared2[IDy*BS+c*numY*BS+i];
	    }
	  }
	}
	for(int c=0;c<ElePerThr;c++){
	  matrixOut[a+b+IDx+(IDy+c*numY)*MW] = values[c];
	}
      }
   }
#endif
}

