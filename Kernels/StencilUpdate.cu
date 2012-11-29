// GPU kernel
__device__ void StencilUpdate(void* param)
{
    float* paramIn = (float*)param;
    int N = (int)paramIn[0];
    float h = paramIn[1];
    float dt = paramIn[2];
    float alpha = paramIn[3];
    float* u = paramIn+5;
    float* u_prev = paramIn+5+N*N;
    // Setting up indices
    int i = threadIdx.x;
    int I = i;
    //if (I>=N*N){return;}    
    while (I < N*N)
    {
    // if not boundary do
    if ( (I>N) && (I< N*N-1-N) && (I%N!=0) && (I%N!=N-1)) 
    {    
        u[I] = u_prev[I] + alpha*dt/(h*h) * (u_prev[I+1] + u_prev[I-1] + u_prev[I+N] + u_prev[I-N] - 4*u_prev[I]);
    }
    I = I + 32;
    }
    // Boundary conditions are automatically imposed
    // as we don't touch boundaries
}

