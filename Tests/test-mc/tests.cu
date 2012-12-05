#include "allocations.cu"
#include <time.h>
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
    int testSize = 10;
    int N = 16;
    N = 65535*8;
    clock_t begin, end;
    double flop = N;
    void* param; void* ret;
    int size = sizeof(int)*(N*3+1);
    param = makeVectorAddArgs(N, size);
    //printf("testAdd: %d,%d\n", N, size);
    begin = clock();
    for (int idx = 1; idx <= testSize; ++idx)
    {
        ret = run(1, 32, param, size);
        free(ret);
    }
    end = clock();
    //printf("Start: %ld, End: %ld\n", begin, end);
    double time = (double)(end - begin)/CLOCKS_PER_SEC;
    time = time/testSize;
    flop = (N/time)*1.0e-6;
    printf("testAdd: N:%d,Size:%.10g MB, time:%.5g s, MFLOP:%.10g\n", 
            N, (double)size/1000000, time, flop);
#if 0 
    for (int idx = 0; idx < N; ++idx)
    {
       int v = A[idx] + B[idx];
       if ( v != C[idx])
       printf("v=%d\n",C[idx]-v); 
    }
#endif
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
    clock_t start, end;
    int ROW = 320;//32*20;
    int size = 0;
    int numTests = 3;
    void* param = makeMatrixMult(ROW, size);
    start = clock();
    for (int idx = 1; idx <= numTests; ++idx)
    {
       //int ROW = 32 << idx;
       ROW = 300;//32*20;
       void* ret = run(4, 32, param,size);
       printf("idx:%d\n",idx);
       free(ret);
    }
    end = clock();
    free(param);
    double time = (double)(end-start)/CLOCKS_PER_SEC;
    time = time/numTests;
    int flops = 2*ROW*ROW*ROW;
    double flop = flops/time;
    flop = flop/1000000;
    printf("Elements: %d, Memory: %d, time: %.5g, gflop: %.5g\n", 
            ROW, size, time, flop); 
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
