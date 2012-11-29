#include <stdio.h>
#include <math.h>
int test(int a, int b)
{
   printf(">>%d, %d\n", a, b);
   return 0;
}

void* allocateArray(int N, int& size)
{
   size = (N+32+1)*sizeof(float);
   float* mem = (float*)malloc(size);
   mem[0] = N;
   float* a1 = mem+1;
   float* b1 = a1+N;
   for (int idx = 0; idx < N; ++idx)
      a1[idx] = 1;
   for (int idx = 0; idx < 32; ++idx)
      b1[idx] = 0;
   return (void*)mem;
}

void* makeVectorArgsAsFloat(int N, int& size)
{
   size = (3*N+1)*sizeof(float);
   float* mem = (float*)malloc(size);
   float* a1 = mem+1;
   float* b1 = a1+N;
   float* c1 = b1+N;
   for (int idx = 0; idx < N; ++idx)
   {
      a1[idx] = 1;
      b1[idx] = 1;
      c1[idx] = 0;
   }
   mem[0] = N;
   return (void*)mem;
}

void* makeVectorArgs(int N, int & size)
{
   size = (3*N+1)*sizeof(int);
   int* mem = (int*)malloc(size);
   int* a1 = mem+1;
   int* b1 = a1+N;
   int* c1 = b1+N;
   for (int idx = 0; idx < N; ++idx)
   {
      a1[idx] = idx;
      b1[idx] = idx;
      c1[idx] = 0;
   }
   mem[0] = N;
   return (void*)mem;
}


void* makeVectorAddArgs(int N, int & size)
{
   size = (3*N+1)*sizeof(float);
   int* mem = (int*)malloc(size);
   int* a1 = mem+1;
   int* b1 = a1+N;
   int* c1 = b1+N;
   for (int idx = 0; idx < N; ++idx)
   {
      a1[idx] = idx;
      b1[idx] = idx;
      c1[idx] = -1;
   }
   mem[0] = N;
   return (void*)mem;
}


float *makeMatrixTranspose(int ROW, int& size)
{
  int COLUMN = ROW;

  int a=0, b=0;
  size = (2*ROW*ROW+1)*sizeof(float);
  float *stuff = (float *) malloc(size);
  stuff[0] = ROW;
  float* matrixIn = stuff+1;
  float* matrixOut = matrixIn + ROW*ROW;
  for(a=0; a<ROW;a++)
  {
      for(b=0; b<COLUMN;b++)
      {
         //matrix[b + a * ROW]=((float)rand())/((float) RAND_MAX);
         matrixIn[b + a * ROW]=b;
         matrixOut[b + a * ROW]=-1;
      }
  }
  return stuff;
}

float *makeMatrixInverse(int ROW, int& size)
{
    float* stuff = makeMatrixTranspose(ROW, size);
    float* matrixIdent = stuff + 1 + ROW*ROW;
    for (int idx = 0; idx < ROW; ++idx)
    {
        for (int jdx = 0; jdx < ROW; ++jdx)
        {
           if (idx == jdx)
              matrixIdent[idx*ROW+jdx] = 1;
           else
              matrixIdent[idx*ROW+jdx] = 0;
        }
    }
    return stuff;
}


void *makeMatrix(int ROW, int& size)
{
  int COLUMN = ROW;

  int a=0, b=0;
  size = (1+2*ROW*COLUMN)*sizeof(float);
  float *stuff = (float *) malloc(size);
  stuff[0] = ROW;
  for(a=0; a<ROW;a++)
  {
    for(b=0; b<COLUMN;b++)
    {
      stuff[a + b * ROW]=((float)rand())/((float) RAND_MAX);
      stuff[a + b * ROW + ROW * COLUMN] = 0.0;
    }
  }
  return stuff;
}

void* makeMatrixMult(int ROW, int& size)
{
  int COLUMN = ROW;
  int a=0, b=0;
  size = (3*ROW*ROW+1)*sizeof(float);
  float *stuff = (float *) malloc(size);
  float* orig = stuff;
  // first parameter is the matrix size
  *stuff = ROW;
  // increment the pointer by one
   stuff = stuff+1;
  for(a=0; a<ROW;a++)
    {
      for(b=0; b<COLUMN;b++)
      {
         stuff[a + b * ROW]= ((float)rand())/((float) RAND_MAX);
         stuff[a + b * ROW + ROW * COLUMN] = 
                     ((float)rand())/((float) RAND_MAX);
         stuff[a + b * ROW + 2*ROW * COLUMN] = 0.0;
      }
    }
  return orig;
}

void* makeMatrixVectorArgs(int ROWS, int& size)
{
    size = (ROWS*ROWS+2*ROWS+1)*sizeof(int);
    int* param = (int*)malloc(size);
    param[0] = ROWS;
    int* matrix = param+1;
    int* vecA = matrix+ROWS*ROWS;
    int* vecB = vecA+ROWS;
    // idx = row
    for (int idx=0;idx<ROWS;++idx)
    {
        // for each column value, jdx = column
        for (int jdx=0;jdx<ROWS;++jdx)
            matrix[jdx+idx*ROWS]=idx;
        vecA[idx]=idx;
        vecB[idx]=idx;
    }
    return (void*)param;
}

void* allocateStencil(int N, int& size)
{
    float xmin     = 0.0f;
    float xmax     = 3.5f;
    //float ymax     = 2.0f;
    float h       = (xmax-xmin)/(N-1);
    float dt    = 0.00001f;    
    float alpha    = 0.645f;
    float time     = 0.4f;

    int steps = ceil(time/dt);
    int I;

    //float *u      = new float[N*N];
    //float *u_host = new float[N*N];

    size = sizeof(float)*(5+2*N*N);
    float* param = (float*)malloc(sizeof(float)*size);
     
    param[0] = N;
    param[1] = h;
    param[2] = dt;
    param[3] = alpha;
    param[4] = N;
    float* u = param+5;
    float* u_host = u + N*N;
    // Generate mesh and intial condition
    for (int j=0; j<N; j++)
    {    for (int i=0; i<N; i++)
        {    I = N*j + i;
            u[I] = 0.0f;
            u_host[I] = 0.0f;
            if ( (i==0) || (j==0)) 
                {u[I] = 200.0f;}
        }
    }

    return (void*)param;
}
float RandFloat(float low, float high)
{
    float t = (float)rand() / (float)RAND_MAX;
    return (1.0f - t) * low + t * high;
}
void* allocateBlackScholes(int N, int& size)
{
    const int   OPT_N = N;//4000000;
    const int   OPT_SZ = OPT_N * sizeof(float);
    const float RISKFREE = 0.02f;
    const float VOLATILITY = 0.30f;
    float *h_CallResultCPU, *h_PutResultCPU;
    float *h_StockPrice, *h_OptionStrike, *h_OptionYears;


    size = OPT_SZ*5+3*sizeof(float);
    
    float* param = (float*)malloc(size);
    param[0] = RISKFREE;
    param[1] = VOLATILITY;
    param[2] = OPT_N;
    h_CallResultCPU = param+3;
    h_PutResultCPU = h_CallResultCPU + OPT_N;
    h_StockPrice = h_PutResultCPU + OPT_N;
    h_OptionStrike = h_StockPrice + OPT_N;
    h_OptionYears = h_OptionStrike + OPT_N;
    srand(5347);
    //Generate options set
    for(int i = 0; i < OPT_N; i++)
    {
        h_CallResultCPU[i] = 0.0f;
        h_PutResultCPU[i]  = -1.0f;
        h_StockPrice[i]    = RandFloat(5.0f, 30.0f);
        h_OptionStrike[i]  = RandFloat(1.0f, 100.0f);
        h_OptionYears[i]   = RandFloat(0.25f, 10.0f);
   }
   return (void*)param;  
}
