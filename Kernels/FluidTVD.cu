#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#ifdef UNIX
#include <stdint.h>
#include <unistd.h>
#endif

/*
 * THIS FUNCTION 
 * This is the Cuda Fluid TVD function; It takes a single forward-time step, CFD or MHD, of the
 * conserved-transport part of the fluid equations using a total variation diminishing scheme to
 * perform a non-oscillatory update.
 * requires predicted half-step values from a 1st order upwind scheme.
*/

#define BLOCKLEN 28
#define BLOCKLENP2 30
#define BLOCKLENP4 32

__device__ __inline__ double fluxLimiter_Vanleer(double derivL, double derivR);

#define RHOMIN fluidParams[0]
#define MIN_ETHERM fluidParams[1]

__device__ void cukern_TVDStep_hydro_uniform(void* params)
{
    //uint start, stop;
    //start = clock();
    double fluidParams[2];
    //printf("GPU: GEBUG LOG 1\n");
    int tid = threadIdx.x % 32;
    double* paramsIn = (double*)params;

    /*
     * Get dimensions
     */
    int nx = (int)paramsIn[0];

    paramsIn = paramsIn + 1;
    int ny = (int)paramsIn[0];

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
     * Get P
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* P = paramsIn; 

    /*
     * Output variable
     */

    /*
     * Get rho_out
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* rho_out = paramsIn;

    /*
     * Get E_out
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* E_out = paramsIn;

    /*
     * Get px_out
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* px_out = paramsIn;

    /*
     * Get py_out
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* py_out = paramsIn;

    /*
     * Get pz_out
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* pz_out = paramsIn;

    /*
     * Get Cfreeze
     */
    paramsIn = paramsIn + nx*ny*nz;
    double* Cfreeze = paramsIn; 

    /*
     * Get lambda
     */
    paramsIn = paramsIn + ny*nz;
    double lambda = paramsIn[0]; 

    /*
     * Get rhomin
     */
    paramsIn = paramsIn + 1;
    double rhomin = paramsIn[0]; 

    /*
     * Get gamma
     */
    paramsIn = paramsIn + 1;
    double gamma = paramsIn[0]; 

    fluidParams[0] = rhomin;
// assert     cs > cs_min
//     g P / rho > g rho_min^(g-1)
// (g-1) e / rho > rho_min^(g-1)
//             e > rho rho_min^(g-1)/(g-1)
    //printf("GPU :: rhomin %lf, gamma %lf\n", rhomin, gamma);
    fluidParams[1] = pow(rhomin, gamma-1.0)/(gamma-1.0);
    double halfLambda = 0.5 * lambda;

    //cukern_TVDStep_hydro_uniform                         (*rho,    *E,     *px,      *py,     *pz,     *P,      *Cfreeze, *rhoW,  *enerW,     *pxW,     *pyW,     *pzW,     lambda, nx);
    double C_f, velocity;
    double q_i[5];
    double w_i;
    double* fluxLR = (double *) gemtcSharedMemory();
    double* fluxDerivA = fluxLR + BLOCKLENP4*2;
    double* fluxDerivB = fluxDerivA + BLOCKLENP4 + 1;
    //printf("ThreadIdx %d\n", threadIdx.x);
    //return;
    for(int i = 0; i < ny; i++) {
        for(int j = 0; j < nz; j++) {

            /* 
             * Step 0 - obligatory setup 
             */
            int I0 = nx*(i + j*ny);
            int Xindex = (tid-2);
            int Xtrack = Xindex;
            Xindex += nx*(tid < 2);

            int x; /* = Xindex % nx; */
            int k;
            bool doIflux = (tid > 1) && (tid < BLOCKLENP2);
            double prop_i[5];

            unsigned int threadIndexL = (tid-1+BLOCKLENP4)%BLOCKLENP4;

            /* 
             * Step 1 - calculate W values 
             */
            C_f = Cfreeze[i + j*ny];

            while(Xtrack < nx+2) {
                //printf("tid = %d, i = %d\n", tid, i);
                x = I0 + (Xindex % nx);

                q_i[0] = rho[x]; /* Preload these out here */
                q_i[1] = E[x]; /* So we avoid multiple loops */
                q_i[2] = px[x]; /* over them inside the flux loop */
                q_i[3] = py[x];
                q_i[4] = pz[x];
                velocity = q_i[2] / q_i[0];

                /* rho, E, px, py, pz going down */
                /* Iterate over variables to flux */
                for(k = 0; k < 5; k++) {
                    /* Step 1 - Calculate raw fluxes */
                    switch(k) {
                        case 0: w_i = q_i[2]; break;
                        case 1: w_i = (velocity * (q_i[1] + P[x]) ) ; break;
                        case 2: w_i = (velocity * q_i[2] + P[x]); break;
                        case 3: w_i = (velocity * q_i[3]); break;
                        case 4: w_i = (velocity * q_i[4]); break;
                    }

                    /* Step 2 - Decouple to L/R flux */
                    /* NOTE there is a missing .5 here, accounted for in the h(al)f of lambdahf */
                    fluxLR[tid] = (C_f*q_i[k] - w_i); /* Left  going flux */
                    fluxLR[BLOCKLENP4 + tid] = (C_f*q_i[k] + w_i); /* Right going flux */
                    //__syncthreads();

                    /* Step 3 - Differentiate fluxes & call limiter */
                    /* left flux */
                    fluxDerivA[tid] = fluxLR[threadIndexL] - fluxLR[tid];
                    fluxDerivB[tid] = fluxLR[BLOCKLENP4 + tid] - fluxLR[BLOCKLENP4 + threadIndexL];
                    //__syncthreads();
        
                    /* right flux */
                    fluxLR[tid] += fluxLimiter_Vanleer(fluxDerivA[tid], fluxDerivA[tid+1]);
                    fluxLR[BLOCKLENP4 + tid] += fluxLimiter_Vanleer(fluxDerivB[tid+1], fluxDerivB[tid]);
                    //__syncthreads();

                    /* Step 4 - Perform flux and write to output array */
                    if( doIflux && (Xindex < nx) ) {
                        switch(k) {
                            case 0:
                                prop_i[0] = rho_out[x] - halfLambda * ( fluxLR[tid] - fluxLR[tid+1] + \
                                                   fluxLR[BLOCKLENP4 + tid] - fluxLR[BLOCKLENP4 + threadIndexL]  );
                                break;
                            case 1:
                                prop_i[1] = E_out[x] - halfLambda * ( fluxLR[tid] - fluxLR[tid+1] + \
                                                   fluxLR[BLOCKLENP4 + tid] - fluxLR[BLOCKLENP4 + threadIndexL]  );
                                break;
                            case 2:
                                prop_i[2] = px_out[x] - halfLambda * ( fluxLR[tid] - fluxLR[tid+1] + \
                                                   fluxLR[BLOCKLENP4 + tid] - fluxLR[BLOCKLENP4 + threadIndexL]  );
                                break;
                            case 3:
                                prop_i[3] = py_out[x] - halfLambda * ( fluxLR[tid] - fluxLR[tid+1] + \
                                                   fluxLR[BLOCKLENP4 + tid] - fluxLR[BLOCKLENP4 + threadIndexL]  );
                                break;
                            case 4:
                                prop_i[4] = pz_out[x] - halfLambda * ( fluxLR[tid] - fluxLR[tid+1] + \
                                                   fluxLR[BLOCKLENP4 + tid] - fluxLR[BLOCKLENP4 + threadIndexL]  );
                                break;
                        }
                    }
                    //__syncthreads();
                }

                if( doIflux && (Xindex < nx) ) {
                    prop_i[0] = (prop_i[0] < RHOMIN) ? RHOMIN : prop_i[0];
                    w_i = .5*(prop_i[2]*prop_i[2] + prop_i[3]*prop_i[3] + prop_i[4]*prop_i[4])/prop_i[0];

                    if((prop_i[1] - w_i) < prop_i[0]*MIN_ETHERM) {
                        prop_i[1] = w_i + prop_i[0]*MIN_ETHERM;
                    }

                    rho_out[x] = prop_i[0];
                    E_out[x] = prop_i[1];
                    px_out[x] = prop_i[2];
                    py_out[x] = prop_i[3];
                    pz_out[x] = prop_i[4];
                }

                //__syncthreads();

                Xindex += BLOCKLEN;
                Xtrack += BLOCKLEN;
            }
        }
    }
    //stop = clock();
    //float time;
    //if (stop > start) {
    //    time = (float)(stop - start)/(float)SHADER_CLOCK;
    //} else {
    //    time = (float)(stop + (0xffffffff - start))/(float)SHADER_CLOCK;
    //}
    //printf("Time taken %f ms\n", time);    
}

__device__ double fluxLimiter_Vanleer(double derivL, double derivR)
{
    double r;

    r = derivL * derivR;
    if(r < 0.0) { r = 0.0; }

    r = r / ( derivL + derivR);
    if (isnan(r)) { r = 0.0; }

    return r;
}


