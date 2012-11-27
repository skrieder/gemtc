#include "allocations.cu"

void testSleep()
{
    int sleepTime = 5;
    void* ret = run(0, 32, &sleepTime, sizeof(int));
    free(ret);
}
void testAdd()
{
    void* param; void* ret;
    // runs a task on the gpu
    int size = sizeof(float)*(32*3+1);
    param = makeVectorAddArgs(64, size);
    ret = run(1, 32, param, size);
    free(ret);free(param);
}

void testVectorProduct()
{
    int size = sizeof(float)*(32*3+1);
    void* param = makeVectorAddArgsFloat(size);
    void* ret = run(3, 32, param, size);
    free(ret);free(param);
}

void testMatrixSquare()
{
    int ROW = 32;
    int size = 0;
    void* param = makeMatrixTranspose(ROW, size);
    void* ret = run(2, 32, param,size);
    free(ret);free(param);
}
    
void testMatrixMultiply()
{
    int ROW = 32;
    int size = 0;
    void* param = makeMatrixMult(ROW, size);
    void* ret = run(4, 32, param,size);
    free(ret);free(param);
}

void testMatrixTranspose()
{
    int ROW = 32; int COLUMN = 32; int number = 1;
    int size = (number*ROW*COLUMN);
    void* param = makeMatrixTranspose(ROW, size);
    void* ret = run(5, 32, param,size);
    free(ret);free(param);
}

void testMatrixVector()
{
    int ROW = 512; int size = 0;
    void* param = makeMatrixVectorArgs(ROW, size);
    void* ret = run(6, 32, param,size);
    free(ret);free(param);
}

void testMatrixInverse()
{
    int ROW = 3; int size = 0;
    void* param = makeMatrixInverse(ROW, size);
    void* ret = run(7, 32, param,size);
    free(ret);free(param);
}

