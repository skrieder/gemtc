__device__ void MatrixInverse(  void* param)
{
    float* paramIn = (float*)param;
    int N = (int)paramIn[0];
    paramIn = paramIn+1;
    float* A = paramIn;
    float* B = paramIn+N*N;
    int x = threadIdx.x;
    if (x < N)
    {
   for (int y = 0; y < N; ++y)
   { 
       float pivot = 0;
       for (int i = 0; i < N; ++i)
       {
           pivot = A[N*y+i]/A[N*i+i];
           if (y != i )
           {
               A[N*y+x] = A[N*y+x]-(pivot*A[N*i+x]);
               B[N*y+x] = B[N*y+x]-(pivot*B[N*i+x]);
           }
       }
   }
   for (int y = 0; y < N; ++y)
   {
      for (int i = 0; i < N; ++i)
      {
          if (y == i)
          {
              B[N*y+x] /= A[N*y+y];
              float div = A[N*y+y];
              A[N*y+y] /= div; 
          }
       }
   }
   }
}
