__device__ void StencilCopy(void* param)
{
    float* paramIn = (float*)param;
    int N = (int)paramIn[0];
    float* u = paramIn+5;
    float* u_prev = paramIn+5+N*N;
    int i = threadIdx.x;
    int I = i;
    while (I < N*N)
    {
        //if (I>=N*N){return;}    
        u_prev[I] = u[I];
        I = I + 32;
    }
}

