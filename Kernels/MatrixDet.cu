#include <stdio.h>
//__device__ float Determinant(float *a,int n,float *temp);
__device__ __shared__ float result[3];
__device__ void MatrixDeterminant(void *param)
{ 
    float *input = (float *) param;
    int warp_size=32;
    int n = (int)input[0];
    float* matrix = input+1;
    int thread = threadIdx.x % warp_size;
    float value =0;
    float *det = matrix +n*n;   
    if(n < 1){
    //Error return 0
    value = 0; 
    }
    else {
    if(n==1) 
     value = matrix[0];
    else if(n==2) 
     value =  matrix[0] * matrix[3] - matrix[2] * matrix[1];
    else if (n==3){
      if(thread < 3){
      result[thread] = pow(-1.0,thread) *(matrix[thread]*(matrix[1*n + (thread+1)%3]*matrix[2*n + (thread+2)%3] - matrix[1*n + (thread+2)%3]*matrix[2 *n + (thread+1)%3]));
    } 
    }
    else
	value = 0;//This program works only for n=1 to 3   
    }
    if(n==3 && thread ==0)
    {
     for(int i=0; i < n; i++)
     {
     value = value + result[i];
     }
    *det = value;
    }
   else if(n<3) 
    *det = value;
    
}

//Recursive function not working 
/*
__device__ float Determinant(float *a,int n,float *m)
{

   int i,j,j1,j2;
   float det = 0;
   printf("%dInput\n",n);
   if (n < 1) { * Error 

   } else if (n == 1) { /* Shouldn't get used 
      det = a[0];
   } else if (n == 2) {
      det =  a[0] * a[3] - a[2] * a[1];
   } else {
      det = 0;
      for (j1=0;j1<n;j1++) {
  //       m = (float *)malloc((n-1)*(n-1) * sizeof(float));
        // for (i=0;i<n-1;i++)
          //  m[i] = (float *)malloc((n-1)*sizeof(float));
         for (i=1;i<n;i++) {
            j2 = 0;
            for (j=0;j<n;j++) {
               if (j == j1)
                  continue;
               m[(i-1)*n+j2] = a[i * n + j];
               j2++;
            }
         }
         det += pow(-1.0,1.0+j1+1.0) * a[j1] * Determinant(m,n-1,a);
	 printf("%f Intermidiate det\n", det);
        // free(m);
      }
   }
   return(det);
}*/
