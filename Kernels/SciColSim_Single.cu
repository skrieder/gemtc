/*
 * Application:- SciColSim's expensive function update_probabilities_all_visible() from "scicolsim-2013-03-07/src/optimizer.cpp"
 * Purpose:-
 *    It implements the GeMTC kernel for gemtc_update_probabilities_all_visible() of scicolsim application.
 * Difference from SciColSim.cu, this does the whole processing by 1 thread in the warp.
 * Hence has been developed for efficiency comparison.
 *
 * How to use:-
 *     Replace SciColSim.cu with this file.
 * mv SciColSim.cu SciColSim_Warp.cu
 * mv SciColSim_Single.c SciColSim.cu
 * build scicolsim application.
 */
#include <cfloat>

/*
 * Type used to represent state of edge (final and tried)
 * Use bitfield so compact in memory
typedef struct {
    bool final : 1;
    bool tried : 1;
} edge_state;
 */

/*
 * Shader frequency of GTX 480 
 * Better will be to deriver this in case we are simulation in a different GPU
 * But calling function to derive frequncy so many times will be still expensive
 * Tip:- Get this from the caller as input parameter.
 */
#define SHADER_CLOCK 1401000
typedef struct {
    int final;
    int tried;
} edge_state;

__device__ void gemtc_update_probabilities_all_visible(void* params)
{
    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //uint start, stop;
    //start = clock();
    if (threadIdx.x % 32 != 0) {
        //printf("GPU Returning thread %d\n", threadIdx.x);
        return;
    }
    int N_nodes, warp_size = 32;

    //double *Summa = (double *) gemtcSharedMemory();
    double Summa = 0.;
    /*
     * Get input parameters
     */
    double* paramsIn = (double*)params;

    /*
     * First argument is basis of getting into this function
     */
    paramsIn = paramsIn + 1;
    /*
     * Pre-compute logs
     */
    N_nodes = (int)paramsIn[0];
    //printf(" thread %d::N_nodes %d\n", threadIdx.x, N_nodes);

    /*
     * Alpha i
     */
    paramsIn = paramsIn + 1;
    double alpha_i = (double)paramsIn[0];
    //printf(" thread %d::Alpha_i %f\n", threadIdx.x, alpha_i);

    /*
     * Alpha m
     */
    paramsIn = paramsIn + 1;
    double alpha_m = (double)paramsIn[0];
    //printf(" thread %d::Alpha_m %f\n", threadIdx.x, alpha_m);

    /*
     * k_max     
     */
    paramsIn = paramsIn + 1;
    double k_max = (double)paramsIn[0];
    printf(" thread %d::k_max %f\n", threadIdx.x, k_max);

    /*
     * beta     
     */
    paramsIn = paramsIn + 1;
    double beta = (double)paramsIn[0];
    //printf(" thread %d::Beta %f\n", threadIdx.x, beta);

    /*
     * gamma 
     */
    paramsIn = paramsIn + 1;
    double gamma = (double)paramsIn[0];
    //printf(" thread %d::gamma %f\n", threadIdx.x, gamma);

    /*
     * delta 
     */
    paramsIn = paramsIn + 1;
    double delta = (double)paramsIn[0];
    //printf(" thread %d::Delta%f\n", threadIdx.x, delta);

    /*
     * Total probability 
     */
    paramsIn = paramsIn + 1;
    //double TotalProb = (double)paramsIn[0];
    //printf(" thread %d::Total_probability %f\n", threadIdx.x, TotalProb);

    /*
     * LogRanks
     */
    paramsIn = paramsIn + 1;
    double *LogRanks = (double*)paramsIn;

    /*
     * Rank
     */
    paramsIn = paramsIn + N_nodes;
    double *Rank = (double*)paramsIn;
    //for (int i = threadIdx.x; i < N_nodes; i+=warp_size) {
    for (int i = 0; i < N_nodes; i++) {
        LogRanks[i] = log(Rank[i]+1.);
    }

    /*
     * ProbSums
     */
    paramsIn = paramsIn + N_nodes;
    double *ProbSums = (double*)paramsIn;

    /*
     * Prob
     */
    paramsIn = paramsIn + N_nodes;
    double* Prob = (double*)paramsIn;

    /*
     * Dist
     */
    paramsIn = paramsIn + N_nodes*N_nodes;
    double* Dist = (double*)paramsIn;

    /*
     * State
     */
    paramsIn = paramsIn + N_nodes*N_nodes;
    edge_state *State = (edge_state*)paramsIn;
    paramsIn = paramsIn + N_nodes*N_nodes;
/*
        printf(" GPU STATE\n");
    for(int i=0; i<5;i++) {
        for(int j=0;j<5;j++) {
            printf("    State[%d][%d].final = %d:: State[%d][%d].tried = %d", i, j, State[i*N_nodes + j].final, i, j, State[i*N_nodes + j].tried);
        }
        printf("\n");
    }
        printf("\n");
*/
    printf("GPU: DEBUG LOG 1 size %d\n", paramsIn - (double*)params);
    /*
     * Compute sampling probabilities 
     * first pass: \xi_i,j
     */

    //for(int i = threadIdx.x; i < N_nodes-1; i+=warp_size){
    for(int i = 0; i < N_nodes-1; i++){
        double probSum = 0.0;
        for( int j=i+1; j<N_nodes; j++){
    //printf("GPU: i=%d j=%d\n", i, j);
                
            if(!State[i*N_nodes + j].tried){
                double bg = 0.;
                Prob[i*N_nodes + j] = alpha_i*min(LogRanks[i], LogRanks[j]) +
                  alpha_m*max(LogRanks[i], LogRanks[j]);  
                
                if (Dist[i*N_nodes + j] > 0.){
                    
                    double k = Dist[i*N_nodes + j];
                    if (k >= k_max){
                        k = k_max-1;
                    }
                    
                    bg = beta * log(k/k_max) + gamma * log(1. - k/k_max);
                    
                } else {
                    bg = delta;
                }
                   
                Prob[i*N_nodes + j] = exp(Prob[i*N_nodes + j] + bg);
                /*
                 * Probability can tip over into infinite in rare cases.
                 * Return to representable number to avoid strange behavior
                 */
                if (!isfinite(Prob[i*N_nodes + j])) {
                  //printf("DEBUG: Invalid Prob[%i][%i]: %.17g\n",
                  //        i, j, Prob[i][j]);
                  if (isnan(Prob[i*N_nodes + j])) {
                    Prob[i*N_nodes + j] = DBL_MIN;
                  } else {
                    Prob[i*N_nodes + j] = DBL_MAX;
                  }
                }
                if (Prob[i*N_nodes + j] == 0.0) {
                  /*
                   * Don't want zero prob: otherwise will never be sample
                   */
                  //printf("DEBUG: Prob[%i][%i] == 0.0\n", i, j);
                  Prob[i*N_nodes + j] = DBL_MIN;
                }
                probSum += Prob[i*N_nodes + j];
            }
        }
        ProbSums[i] = probSum;
        Summa += probSum;
    }
    printf("GPU: DEBUG LOG 4\n");

    /*
     * Reduction to get summation
    int local_sum = 0.;
    for(int i = threadIdx.x; i < N_nodes-1; i+=warp_size){
        local_sum += ProbSums[i];
    }
    Summa[threadIdx.x] = local_sum;
    __syncthreads();

    while((warp_size >> 1) > 0) {
        if(threadIdx.x < warp_size) {
            Summa[threadIdx.x] += Summa[threadIdx.x + warp_size];
        }
        __syncthreads();
    }
     */

    printf("Summa = %f\n", Summa);
    /*
     * second pass: normalize
     */
    //if (isfinite(Summa[0])) {
    if (!isfinite(Summa)) {
      /*
       * Need to avoid dividing by infinity
       */
      //printf("DEBUG: infinite prob summ: %.17g\n", Summa);
      //Summa[0] = DBL_MAX;
      Summa = DBL_MAX;
    }

    //for(int i=threadIdx.x; i<N_nodes-1; i+=warp_size){
    for(int i=0; i<N_nodes-1; i++){
        for( int j=i+1; j<N_nodes; j++){
                
            if(!State[i*N_nodes + j].tried){
                //Prob[i*N_nodes + j] /= Summa[0];
                Prob[i*N_nodes + j] /= Summa;
            }
        }
        //ProbSums[i] /= Summa[0];
        ProbSums[i] /= Summa;
    }
    /*
     * Sum should be 1, since normalized
     */
    //TotalProb = 1.;
    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //stop = clock();
    //float time;
    //if (stop > start) {
    //    time = (float)(stop - start)/(float)SHADER_CLOCK;
    //} else {
    //    time = (float)(stop + (0xffffffff - start))/(float)SHADER_CLOCK;
    //}
    //printf("GPU: Time taken %f ms\n", time);    
    return;
}

__device__ void gemtc_sample_all_visible(void *param)
{
    return;
}

__device__ void gemtc_scicolsim(void *params)
{
    double *operation = (double*)params;

    switch((int)*operation) {
    case 1:
        gemtc_update_probabilities_all_visible(params);
        break;
    case 2:
        gemtc_sample_all_visible(params);
        break;
    };
}
