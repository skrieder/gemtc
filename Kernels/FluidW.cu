/*
 * Application:- Imogen's ported cukern_Wstep_hydro_uniform() kernel from "gpuImogen/gpuclass/cudaFluidW.cu"
 * Purpose:-
 *    This function calculates a first order accurate half-step of the conserved transport part of the fluid equations (CFD)
 * which is used as the predictor input to the matching TVD function. The kernel implemented is purehydro implying magnetic
 * parameters are zero.
 * 
 * The 1D segment of the fluid equations solved is
 *         | rho |         | px |
 *         | px  |         | vx px + P - bx^2 |
 *    d/dt | py  | = -d/dx | vx py - bx by |
 *         | pz  |         | vx pz - bx bz |
 *         | E   |         | vx (E+P) - bx (B dot v) |
 *
 * with auxiliary equations
 * vx = px / rho
 * P = (gamma-1)e + .5*B^2 = thermal pressure + magnetic pressure
 * e = E - .5*(p^2)/rho - .5*(B^2)
 * (The relation between internal energy e and thermal pressure is theoretically allowed to be far more complex than the ideal 
 * gas law being used). The hydro functions solve the same equations with B set to <0,0,0>.
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
#define BLOCKLEN 28
#define BLOCKLENP2 30
#define BLOCKLENP4 32

#define ALFVEN_FACTOR 1

/*
 * Shader frequency of GTX 480 
 * Better will be to deriver this in case we are simulation in a different GPU
 * But calling function to derive frequncy so many times will be still expensive
 * Tip:- Get this from the caller as input parameter.
 */
#define SHADER_CLOCK 1401000

/*
 * This function calculates a single half-step of the conserved transport part of the fluid equations
 * (CFD or MHD) which is used as the predictor input to the matching TVD function.
 */
__device__ void cukern_Wstep_hydro_uniform(void* params)
{
    /*
     * Kernel Benchmarking parameters
     * Uncomment to benchmark inside CUDA kernel.
     * Don't uncomment otherwise else it will lead to unnecessary console logs.
     */
    //uint start, stop;
    //start = clock();
    //printf("Entering thread %d\n", threadIdx.x);
    double fluidQtys[7];
#define FLUID_GAMMA   fluidQtys[0]
#define FLUID_GM1     fluidQtys[1]
#define FLUID_GG1     fluidQtys[2]
#define FLUID_MINMASS fluidQtys[3]
#define FLUID_MINEINT fluidQtys[4]

#define MHD_PRESS_B   fluidQtys[5]
#define MHD_CS_B      fluidQtys[6]

    //printf("GPU: GEBUG LOG 1\n");
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
     * Get Ptot
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* Ptot = paramsIn; 

    /*
     * Get c_f
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* Cfreeze = paramsIn; 

    /*
     * Get lambda
     */
    paramsIn = paramsIn + ny*nz;
    double lambda = paramsIn[0]; 

    /*
     * Get gamma
     */
    paramsIn = paramsIn + 1;
    double gamma = paramsIn[0]; 

    /*
     * Get rhomin
     */
    paramsIn = paramsIn + 1;
    double rhomin = paramsIn[0]; 

    /*
     * Output variable
     */

    /*
     * Get rhow
     */
    paramsIn = paramsIn + 1;
    double* rhow = paramsIn;

    /*
     * Get Ew
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* Ew = paramsIn;

    /*
     * Get pxw
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* pxw = paramsIn;

    /*
     * Get pyw
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* pyw = paramsIn;

    /*
     * Get pzw
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* pzw = paramsIn;

    /*
     * Get pressb
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* pressb = paramsIn;


    //printf("GPU: GEBUG LOG 2\n");
    fluidQtys[0] = gamma;
    fluidQtys[1] = gamma-1.0;
    fluidQtys[2] = gamma*(gamma-1.0);
    fluidQtys[3] = rhomin;
    // assert     cs > cs_min
    //     g P / rho > g rho_min^(g-1)
    // (g-1) e / rho > rho_min^(g-1)
    //             e > rho rho_min^(g-1)/(g-1)
    fluidQtys[4] = pow(rhomin, gamma-1.0)/(gamma-1.0);
    fluidQtys[5] = 1.0 - .5*gamma;
    fluidQtys[6] = ALFVEN_FACTOR - .5*(gamma-1.0)*gamma;

    double lambdaqtr = 0.25 * lambda; 
 
#define FLUXLa_OFFSET 0
#define FLUXLb_OFFSET (BLOCKLENP4)
#define FLUXRa_OFFSET (2*(BLOCKLENP4))
#define FLUXRb_OFFSET (3*(BLOCKLEN+4))
    #define FLUXA_DECOUPLE(i) fluxArray[FLUXLa_OFFSET+tid] = q_i[i]*C_f - w_i; fluxArray[FLUXRa_OFFSET+tid] = q_i[i]*C_f + w_i;
    #define FLUXB_DECOUPLE(i) fluxArray[FLUXLb_OFFSET+tid] = q_i[i]*C_f - w_i; fluxArray[FLUXRb_OFFSET+tid] = q_i[i]*C_f + w_i;

    #define FLUXA_DELTA lambdaqtr*(fluxArray[FLUXLa_OFFSET+tid] - fluxArray[FLUXLa_OFFSET+tid+1] + fluxArray[FLUXRa_OFFSET+tid] - fluxArray[FLUXRa_OFFSET+tid-1])
    #define FLUXB_DELTA lambdaqtr*(fluxArray[FLUXLb_OFFSET+tid] - fluxArray[FLUXLb_OFFSET+tid+1] + fluxArray[FLUXRb_OFFSET+tid] - fluxArray[FLUXRb_OFFSET+tid-1])

#define momhalfsq momhalfsq

    double C_f, velocity;
    double q_i[3];
    double w_i;
    double velocity_half;

    double* fluxArray = (double *) gemtcSharedMemory();
    //double fluxArray[4*BLOCKLENP4];

    double* freezeSpeed = fluxArray + 4*(BLOCKLENP4);
    //double freezeSpeed[BLOCKLENP4];
    //return;

    /*
     * Traverse 3-D data and solve the equations
     */
    for(int i = 0; i < ny; i++) {
        for(int j = 0; j < nz; j++) { 
            //printf("GPU: Iteration %d\n", j);
            freezeSpeed[tid] = 0;

            /*
             * Do NOT memset(), instead chop the setting functions for 32 threads to process
             */
            for(int k = tid; k < 4*(BLOCKLENP4); k+=32) {
                fluxArray[k] = 0.0;
            }
            //if(tid == 0) memset(fluxArray, 0, sizeof(double)*4*(BLOCKLENP4));

            /*
             * Step 0 - obligatory setup 
             */
            int I0 = nx*(i + j*ny);
            int Xindex = (tid-2);
            int Xtrack = Xindex;
            Xindex += nx*(tid < 2);

            int x; /* = Xindex % nx; */
            bool doIflux = (tid > 1) && (tid < BLOCKLEN+2);

            /*
             * Step 1 - calculate W values 
             */
            C_f = Cfreeze[i + j*ny];

            double locPsq;
            double locE;

            /*
             * int stopme = (blockIdx.x == 0) && (blockIdx.y == 0); // For cuda-gdb
             */

            while(Xtrack < nx+2) {
                x = I0 + (Xindex % nx);

           //printf("GPU DEBUGING 1 %d \n", tid);
                /*
                 * rho q_i[0] = inputPointers[0][x];  Preload these out here 
                 * E q_i[1] = inputPointers[1][x];  So we avoid multiple loops 
                 * px q_i[2] = inputPointers[2][x];  over them inside the flux loop 
                 * py q_i[3] = inputPointers[3][x];  
                 * pz q_i[4] = inputPointers[4][x];  
                 */

                q_i[0] = rho[x];
                q_i[1] = px[x];
                q_i[2] = E[x];
                locPsq = Ptot[x];

                velocity = q_i[1] / q_i[0];

                w_i = velocity*(q_i[2]+locPsq); /* E flux = v*(E+P) */
                FLUXA_DECOUPLE(2)
                w_i = (velocity*q_i[1] + locPsq); /* px flux = v*px + P */
                FLUXB_DECOUPLE(1)
                //__syncthreads();

           //printf("GPU DEBUGING 2 %d \n", tid);
                if(doIflux && (Xindex < nx)) {
                   locE = q_i[2] - FLUXA_DELTA; /* Calculate Ehalf */
                   velocity_half = locPsq = q_i[1] - FLUXB_DELTA; /* Calculate Pxhalf */
                   pxw[x] = locPsq; /* store pxhalf */
                }
                //__syncthreads();
           //printf("GPU DEBUGING 3 %d \n", tid);

               locPsq *= locPsq; /* store p^2 in locPsq */

               q_i[0] = py[x];
               q_i[2] = pz[x];
               w_i = velocity*q_i[0]; /* py flux = v*py */
               FLUXA_DECOUPLE(0)
               w_i = velocity*q_i[2]; /* pz flux = v pz */
               FLUXB_DECOUPLE(2)

               //__syncthreads();

           //printf("GPU DEBUGING 4 %d \n", tid);
               if(doIflux && (Xindex < nx)) {
                   q_i[0] -= FLUXA_DELTA;
                   locPsq += q_i[0]*q_i[0];
                   pyw[x] = q_i[0];
                   q_i[2] -= FLUXB_DELTA;
                   locPsq += q_i[2]*q_i[2]; /* Finished accumulating p^2 */
                   pzw[x] = q_i[2];
               }
               //__syncthreads();

               q_i[0] = rho[x];
               w_i = q_i[1]; /* rho flux = px */
               FLUXA_DECOUPLE(0)
               //__syncthreads();
           //printf("GPU DEBUGING 5 %d \n", tid);

               if(doIflux && (Xindex < nx)) {
                   q_i[0] -= FLUXA_DELTA; /* Calculate rho_half */
                   //      outputPointers[0][x] = q_i[0];
                   q_i[0] = (q_i[0] < FLUID_MINMASS) ? FLUID_MINMASS : q_i[0]; /* Enforce minimum mass density */
                   rhow[x] = q_i[0];

                   velocity_half /= q_i[0]; /* calculate velocity at the halfstep for doing C_freeze */

        
                   locPsq = (locE - .5*(locPsq/q_i[0])); /* Calculate epsilon = E - T */
                   //      P[x] = FLUID_GM1*locPsq; /* Calculate P = (gamma-1) epsilon */

                   // For now we have to store the above before fixing them so the original freezeAndPtot runs unperturbed
                   // but assert the corrected P, C_f values below to see what we propose to do.
                   // it should match the freezeAndPtot very accurately.

                   // assert   cs^2 > cs^2(rho minimum)
                   //     g P / rho > g rho_min^(g-1) under polytropic EOS
                   //g(g-1) e / rho > g rho_min^(g-1)
                   //             e > rho rho_min^(g-1)/(g-1) = rho FLUID_MINEINT
                   if(locPsq < q_i[0]*FLUID_MINEINT) {
                       locE = locE - locPsq + q_i[0]*FLUID_MINEINT; // Assert minimum E = T + epsilon_min
                       locPsq = q_i[0]*FLUID_MINEINT; // store minimum epsilon.
                   } /* Assert minimum temperature */

           //printf("GPU DEBUGING 6 %d, x=%d\n", tid, x);
                   pressb[x] = FLUID_GM1*locPsq; /* Calculate P = (gamma-1) epsilon */
                   Ew[x] = locE; /* store total energy: We need to correct this for negativity shortly */

                   /* calculate local freezing speed */
                   locPsq = abs(velocity_half) + sqrt(FLUID_GG1*locPsq/q_i[0]);
                   if(locPsq > freezeSpeed[tid]) {
                       if((Xtrack > 2) && (Xtrack < (nx-3))) freezeSpeed[tid] = locPsq;
                   }
               }

               Xindex += BLOCKLEN;
               Xtrack += BLOCKLEN;
           //printf("GPU DEBUGING 7 %d \n", tid);
               //__syncthreads();
           }

           //printf("REDUCTION STARTS\n");
           /* 
            * We have a block of 32 threads. Skip computations wisely
            */
           if(tid < 16) {

               if(freezeSpeed[tid+16] > freezeSpeed[tid]) freezeSpeed[tid] = freezeSpeed[tid+16];
               //__syncthreads();
               if(tid < 8) {

                   if(freezeSpeed[tid+8] > freezeSpeed[tid]) freezeSpeed[tid] = freezeSpeed[tid+8];
                   //__syncthreads();
                   if(tid > 4) {

                       if(freezeSpeed[tid+4] > freezeSpeed[tid]) freezeSpeed[tid] = freezeSpeed[tid+4];
                       //__syncthreads();
                       if(tid < 2) {

                           if(freezeSpeed[tid+2] > freezeSpeed[tid]) freezeSpeed[tid] = freezeSpeed[tid+2];
                           //__syncthreads();
                           if(tid < 1) {
                               /*if(tid > 0) return;
                               for(x = 0; x < BLOCKLENP4; x++) { if(freezeSpeed[x] > freezeSpeed[0]) freezeSpeed[0] = freezeSpeed[x]; }
                               Cfreeze[blockIdx.x + gridDim.x * blockIdx.y] = freezeSpeed[0];*/

                               Cfreeze[i + j*ny] = (freezeSpeed[1] > freezeSpeed[0]) ? freezeSpeed[1] : freezeSpeed[0];
                           }
                       }
                   }
               }
           }
           //printf("REDUCTION STOPS\n");
       }
   }
   //printf("Exiting thread %d\n", threadIdx.x);
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

