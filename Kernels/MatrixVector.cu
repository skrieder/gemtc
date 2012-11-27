__device__ void MatrixVector(void* param)
{
    int* paramIn = (int*)param;
    int N = paramIn[0];
    int* A = paramIn+1;
    int* B = paramIn+1+N*N;
    int* C = paramIn+1+N*N+N;
 
    int bx = blockIdx.x; 
    // Assume one block
    bx = 0;
    //int by = blockIdx.y;
    int tx = threadIdx.x%32; 
    // Calculate the row index of the Pd element and M

    int Row = bx * 32 + tx;
  
    for (unsigned int i = Row; i < N; i=i+32)
    {
       //if(i < N)         
       {
          int Pvalue = 0;
          for (unsigned int k = 0; k < N; k++) 
          {
              Pvalue += A[i*N+k] * B[k];
          }
          C[i] = Pvalue;
          //printf("%d=%d\n",i,Pvalue);
       }
    }
}
