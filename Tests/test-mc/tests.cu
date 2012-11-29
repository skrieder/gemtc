#include "allocations.cu"

void testSleep()
{
    int sleepTime = 5;
    void* ret = run(0, 32, &sleepTime, sizeof(int));
    free(ret);
}


void testArrayAvg()
{
    void* param; void* ret;
    int N = 32 << 1;
    int size = sizeof(int)*(N*3+1);
    param = allocateArray(N, size);
    ret = run(12, 32, param, size);
    float* ret1 = (float*)ret;
    ++ret1;
    ret1=ret1+N; 
    printf("N:%d, Size: %d, Average: %f\n",N,size, ret1[0]);
    free(ret);free(param);
}


void testArrayMax()
{
    void* param; void* ret;
    int N = 32 << 10;
    int size = sizeof(int)*(N*3+1);
    param = allocateArray(N, size);
    ret = run(12, 32, param, size);
    float* ret1 = (float*)ret;
    ++ret1;
    ret1=ret1+N; 
    printf("N:%d, Size: %d, Max: %f\n",N,size, ret1[0]);
    free(ret);free(param);
}

void testArrayMin()
{
    void* param; void* ret;
    int N = 32 << 10;
    int size = sizeof(int)*(N*3+1);
    param = allocateArray(N, size);
    ret = run(11, 32, param, size);
    float* ret1 = (float*)ret;
    ++ret1;
    ret1=ret1+N; 
    printf("N:%d, Size: %d, Min: %f\n",N,size, ret1[0]);
    free(ret);free(param);
}

void testAdd()
{
    void* param; void* ret;
    // runs a task on the gpu
    int N = 1024 << 4;
    //N = 32;
    int size = sizeof(int)*(N*3+1);
    param = makeVectorAddArgs(N, size);
    //printf("testAdd: %d,%d\n", N, size);
    ret = run(1, 32, param, size);
    int* ret1 = (int*)ret;
    int* ret2 = (int*)param;
    int* A = ret1+1;
    int* B = A+N;
    int* C = B+N;
    printf("testAdd: N:%d,Size:%d\n", N, size);
#if 0 
    for (int idx = 0; idx < N; ++idx)
    {
       int v = A[idx] + B[idx];
       if ( v != C[idx])
       printf("v=%d\n",C[idx]-v); 
    }
#endif
    free(ret);free(param);
}

void testVectorProduct()
{
    int N = 1024 << 4;
    int size = sizeof(float)*(32*N+1);
    void* param = makeVectorArgsAsFloat(N, size);
    void* ret = run(3, 32, param, size);
#if 1 
    float* ret1 = (float*)ret;
    float* A = ret1+1;
    float* B = A+N;
    float* C = B+N;
    printf("testVectorProduct:N%d,size: %d, Result: %f\n", N, size,C[0]);
#endif
    free(ret);free(param);
}

void testMatrixSquare()
{
    int ROW = (32 << 3) >> 1;
    int size = 0;
    void* param = makeMatrixTranspose(ROW, size);
    void* ret = run(2, 32, param,size);
    printf("testMatrixSquare:N%d,size: %d \n", ROW, size);
#if 0 
    float* ret1 = (float*)ret;
    float* A = ret1+1;
    float* B = A + ROW * ROW;
    float* result = (float*)malloc(ROW*ROW*sizeof(float));
    for (int idx = 0; idx < ROW; ++idx)
    {
        for (int jdx = 0; jdx < ROW; ++jdx)
        {
           float sum = 0;
           for (int kdx = 0; kdx < ROW; ++kdx)
           {
              float a = A[idx*ROW+kdx];
              float b = A[kdx*ROW+jdx];
              sum += a * b;
           }
           result[idx*ROW+jdx] = sum;
        }
    }
    for (int idx = 0; idx < ROW; ++idx)
    {
        for (int jdx = 0; jdx < ROW; ++jdx)
        {
           int kdx = idx*ROW+jdx;
           printf(" %f ", result[kdx] - B[kdx]);
        }
        printf("\n");
    }
    free(result);
#endif
    free(ret);free(param);
}
    
void testMatrixMultiply()
{
    int ROW = 32 << 1;
    int size = 0;
    void* param = makeMatrixMult(ROW, size);
    void* ret = run(4, 32, param,size);
    printf("testMatrixMultiply, Elements: %d, Memory: %d\n", ROW, size); 
    free(ret);free(param);
}

void testMatrixTranspose()
{
    int ROW = 32 << 1; int COLUMN = 32; int number = 1;
    int size = (number*ROW*COLUMN);
    void* param = makeMatrixTranspose(ROW, size);
    void* ret = run(5, 32, param,size);
    printf("testMatrixTranspose, Elements: %d, Memory: %d\n", ROW, size); 
#if 0 
    float* ret1 = (float*)ret;
    float* A = ret1+1;
    float* B = A + ROW * ROW;
    for (int idx = 0; idx < ROW; ++idx)
    {
        for (int jdx = 0; jdx < ROW; ++jdx)
        {
           int kdx = idx*ROW+jdx;
           printf(" %f ", A[kdx]);
        }
        printf("\n");
    }
    printf ("\n---------\n");
    for (int idx = 0; idx < ROW; ++idx)
    {
        for (int jdx = 0; jdx < ROW; ++jdx)
        {
           int kdx = idx*ROW+jdx;
           printf(" %f ", B[kdx]);
        }
        printf("\n");
    }
#endif
    free(ret);free(param);
}

void testMatrixVector()
{
    int ROW = 512; int size = 0;
    void* param = makeMatrixVectorArgs(ROW, size);
    void* ret = run(6, 32, param,size);
    printf("testMatrixVector, Elements: %d, Memory: %d\n", ROW, size); 
    free(ret);free(param);
}

void testMatrixInverse()
{
    int ROW = 3; int size = 0;
    void* param = makeMatrixInverse(ROW, size);
    void* ret = run(7, 32, param,size);
    printf("testMatrixInverse, Elements: %d, Memory: %d\n", ROW, size); 
    free(ret);free(param);
}

void testStencil()
{
   int N  =  128;
   float dt = 0.00001f;
   float time = 0.4f;
   int step = ceil(time/dt);
   int size = 0;
   void* param = allocateStencil( N,size);
   step = 2;
   for (int t=0; t<step; t++)
   {    
        void* ret = run(8, 32, param,size);
        free(ret);
        ret = run(9, 32, param,size);
        free(ret);
        printf("Processing time step: %d\n", t);
   }
   free(param);
}

void testBlackScholes()
{
   int N = 100 << 5;
   int size = 0;
   void *param = allocateBlackScholes(N, size);
   void* ret = run(10,32,param,size);
    printf("testBlackScholes, Elements: %d, Memory: %d\n", N, size); 
   free(ret);
}
