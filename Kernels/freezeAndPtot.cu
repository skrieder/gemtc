/*
 * Application:- Imogen's ported cukern_FreezeSpeed_hydro() kernel from "gpuImogen/gpuclass/freezeAndPtot.cu"
 * Purpose:-
 *     This function is used to derive pressure and freeze parameters to enforce minimum pressure.
 */
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#ifdef UNIX
#include <stdint.h>
#include <unistd.h>
#endif

/*
 * These macros are different from Imogen's macros as we can only have 32 size 
 */
#define BLOCKDIM 32
#define MAXPOW   5

#define ALFVEN_FACTOR 1
/*
 * Shader frequency of GTX 480 
 * Better will be to deriver this in case we are simulation in a different GPU
 * But calling function to derive frequncy so many times will be still expensive
 * Tip:- Get this from the caller as input parameter.
 */
#define SHADER_CLOCK 1401000

/*
 * Kernel for FreezeSpeed_hydro
 */
__device__ void cukern_FreezeSpeed_hydro(void* params)
{
    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //uint start, stop;
    //start = clock();
    double* locBloc = (double*)gemtcSharedMemory();

    double gammafunc[6];
    int tid = threadIdx.x % 32;

    double* paramsIn = (double*)params;

    /*
     * Get X dimension
     */
    int nx = (int)paramsIn[0];

    /*
     * Get Y dimension
     */
    paramsIn = paramsIn + 1;
    int ny = (int)paramsIn[0];

    /*
     * Get Z dimension
     */
    paramsIn = paramsIn + 1;
    int nz = (int)paramsIn[0];

    /*
     * Get rho
     */
    paramsIn = paramsIn + 1;
    double* rho = paramsIn;

    /*
     * Get E
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* E = paramsIn; 

    /*
     * Get px
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* px = paramsIn; 

    /*
     * Get py
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* py = paramsIn; 

    /*
     * Get pz
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* pz = paramsIn; 

    /*
     * Purehydro simulation hence magnetic variables are not needed.
     * We want to avoid unnecessary data transfer b/w CPU <-> GPU
     * Remember the application must also not provide these parameters
     * else offset computation will break
     */
#if 0 
    /*
     * Get bx
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* bx = paramsIn; 

    /*
     * Get by
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* by = paramsIn; 

    /*
     * Get bz
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* bz = paramsIn; 
#endif 
    
    /*
     * Get gamma
     */
    paramsIn = paramsIn + 1;
    double gamma = paramsIn[0]; 

    /*
     * Get cs0
     */
    paramsIn = paramsIn + 1;
    double cs0 = paramsIn[0]; 

    /*
     * Output variable
     */

    /*
     * Get pressa
     */
    paramsIn = paramsIn + 1;
    double* ptot = paramsIn;

    /*
     * Get freezea
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* freeze = paramsIn;

    gammafunc[0] = gamma;
    gammafunc[1] = gamma - 1.0;
    gammafunc[2] = gamma*(gamma-1.0);
    gammafunc[3] = (1.0 - .5*gamma);
    gammafunc[4] = cs0*cs0; // min c_s squared ;
    gammafunc[5] = (ALFVEN_FACTOR - .5*gamma*(gamma-1.0));
  
#define gam gammafunc[0]
#define gm1 gammafunc[1]
#define gg1 gammafunc[2]
#define cs0sq gammafunc[4]

#define PRESSURE Cs
// cs0sq = gamma rho^(gamma-1))

    /*
     * Traverse 3-D data and solve the equations
     */
    for(int i = 0; i < ny; i++) {
        for(int j = 0; j < nz; j++) { 
            int x = tid + nx*(i + ny*j);
            int addrMax = nx + nx*(i + ny*j);

            double Cs, CsMax;
            double psqhf, rhoinv;
            //double gg1 = gam*(gam-1.0);
            //double gm1 = gam - 1.0;


            CsMax = 0.0;
            locBloc[tid] = 0.0;

            while(x < addrMax) {
                rhoinv   = 1.0/rho[x];
                psqhf    = .5*(px[x]*px[x]+py[x]*py[x]+pz[x]*pz[x]);

                PRESSURE = gm1*(E[x] - psqhf*rhoinv);
                if(gam*PRESSURE*rhoinv < cs0sq) {
                    PRESSURE = cs0sq/(gam*rhoinv);
                    E[x] = psqhf*rhoinv + PRESSURE/gm1;
                } /* Constrain temperature to a minimum value */
                ptot[x] = PRESSURE;

                Cs      = sqrt(gamma * PRESSURE *rhoinv) + abs(px[x]*rhoinv);
                if(Cs > CsMax) CsMax = Cs;

                x += BLOCKDIM;
            }

            locBloc[tid] = CsMax;

            //__syncthreads();

            if (tid % 8 == 0) { // keep threads  [0 8 16 ...]

                // Each searches the max of the nearest 8 points
                for(x = 1; x < 8; x++) {
                    if(locBloc[tid+x] > locBloc[tid]) locBloc[tid] = locBloc[tid+x];
                    //__syncthreads();
                }

                // The last thread takes the max of these maxes
                if(tid == 0) {
                    for(x = 8; x < BLOCKDIM; x+= 8) {
                        if(locBloc[x] > locBloc[0]) locBloc[0] = locBloc[x];
                    }

                    // NOTE: This is the dead-stupid backup if all else fails.
                    //if(threadIdx.x > 0) return;
                    //for(x = 1; x < GLOBAL_BLOCKDIM; x++)  if(locBloc[x] > locBloc[0]) locBloc[0] = locBloc[x];

                    freeze[i + ny*j] = locBloc[0];
                }
            }
        }
    }
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
    //printf("Time taken %f ms\n", time);    
}
