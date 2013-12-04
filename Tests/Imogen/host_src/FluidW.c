/*
 * Imogen Host code for benchmarking FluidW
 */
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<unistd.h> 
#include<limits.h>
#include<stdlib.h>
#include<math.h>

#define BLOCKLEN 28
#define BLOCKLENP2 30
#define BLOCKLENP4 32

#define ALFVEN_FACTOR 1

/*
 * This function calculates a single half-step of the conserved transport part of the fluid equations
 * (CFD or MHD) which is used as the predictor input to the matching TVD function.
 */
void FluidW(void* params)
{
    int tid = 0, i, j, k;
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

    //double* fluxArray = (double *) gemtcSharedMemory();
    double fluxArray[4*BLOCKLENP4];

    //double* freezeSpeed = fluxArray + 4*(BLOCKLENP4);
    double freezeSpeed[BLOCKLENP4];
    //return;
    for(i = 0; i < ny; i++) {
        for(j = 0; j < nz; j++) { 
          for(tid = 0; tid < 32; tid++) { 
            //printf("GPU: Iteration %d\n", j);
            freezeSpeed[tid] = 0;

            if(tid == 0) {
                for( k = 0; k < 4*(BLOCKLENP4); k++) fluxArray[k] = 0.0;
            }

            /*
             * Step 0 - obligatory setup 
             */
            int I0 = nx*(i + j*ny);
            int Xindex = (tid-2);
            int Xtrack = Xindex;
            Xindex += nx*(tid < 2);

            int x; /* = Xindex % nx; */
            int doIflux = (tid > 1) && (tid < BLOCKLEN+2);

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
   }
   //printf("Exiting thread %d\n", threadIdx.x);
}

int main(int argc, char **argv){
    int NUM_TASKS, SIMULATION_TYPE;

    struct timespec start, end;
    double time_spent = 0.0;
    int nx, ny, nz;

    if(argc>2){
        NUM_TASKS = atoi(argv[1]);
        SIMULATION_TYPE = atoi(argv[2]);
    } else {
        printf("This test requires two parameters:\n");
        printf("int NUM_TASKS, int SIMULATION_TYPE\n");
        printf("where  NUM_TASKS is the total tasks\n");
        printf("SIMULATION_TYPE 1 for 12*12*12 size simulation, 2 for 128*124*119 size simulation; 3 for 333*69*100 size simulation\n");
        exit(1);
    }

    //printf("DEBUG LOG 1\n");

    int i, j, k;
    int size, output_start, output_len;

    switch(SIMULATION_TYPE) {
        case 1:
            size = 6*sizeof(double) + (12*12*12)*12*sizeof(double) + (12*12)*sizeof(double);
            output_start = 6 + (12*12*12)*6 + (12*12);
            output_len = (12*12*12)*6*sizeof(double);
            break;
        case 2:
            size = 6*sizeof(double) + (128*124*119)*12*sizeof(double)  + (124*119)*sizeof(double);
            output_start = 6 + (128*124*119)*6  + (124*119);
            output_len = (128*124*119)*6*sizeof(double);
            break;
        case 3:
            size = 6*sizeof(double) + (333*69*100)*12*sizeof(double) +  (69*100)*sizeof(double);
            output_start = 6 + (333*69*100)*6 +  (69*100);
            output_len = (333*69*100)*6*sizeof(double);
            break;
        default:
            size = 6*sizeof(double) + (12*12*12)*12*sizeof(double) + (12*12)*sizeof(double);
            output_start = 6 + (12*12*12)*6 + (12*12);
            output_len = (12*12*12)*6*sizeof(double);
            break;
    }

    //printf("DEBUG LOG 2\n");
    /*
     * Allocate host memory
     */ 
    double *h_params = (double *) malloc(size);
    double *d_params = NULL;
    for(i=0; i < size/sizeof(double); i++) h_params[i] = 0.0;

    /*
     * Set nx, ny, nz
     */
    switch(SIMULATION_TYPE) {
        case 1:
            nx = h_params[0] = 12.0;
            ny = h_params[1] = 12.0;
            nz = h_params[2] = 12.0;
            break;
        case 2:
            nx = h_params[0] = 128.0;
            ny = h_params[1] = 124.0;
            nz = h_params[2] = 119.0;
            break;
        case 3:
            nx = h_params[0] = 333.0;
            ny = h_params[1] = 69.0;
            nz = h_params[2] = 100.0;
            break;
        default:
            nx = h_params[0] = 12.0;
            ny = h_params[1] = 12.0;
            nz = h_params[2] = 12.0;
            break;
    }
    //printf("DEBUG LOG 3\n");

    /*
     * ngrid
     */
    double* xpos = (double*) malloc(nx*ny*nz*sizeof(double));
    double* ypos = (double*) malloc(nx*ny*nz*sizeof(double));
    double* zpos = (double*) malloc(nx*ny*nz*sizeof(double));
    
    double* rho = (h_params + 3);

    for (i = 0; i < nx; i++) {
        for (j = 0; j < ny; j++) {
            for (k = 0; k < nz; k++) {
                xpos[i*ny*nz + j*nz + k] = (i+1)*2*M_PI/(nx);
                ypos[i*ny*nz + j*nz + k] = (j+1)*2*M_PI/(ny);
                zpos[i*ny*nz + j*nz + k] = (k+1)*2*M_PI/(nz);
                rho[i*ny*nz + j*nz + k] = 1.0;
            }
        }
    }
    //printf("DEBUG LOG 4\n");

    double *E = rho + (nx*ny*nz);
    double *px = E + (nx*ny*nz);
    double *py = px + (nx*ny*nz);
    double *pz = py + (nx*ny*nz);
    double *ptot = pz + (nx*ny*nz);
    double *freezespeed = ptot + (nx*ny*nz);

    /*
     * px
     */
    for (i = 0; i < nx; i++) {
        for (j = 0; j < ny; j++) {
            for (k = 0; k < nz; k++) {
                px[i*ny*nz + j*nz + k] = sin(xpos[i*ny*nz + j*nz + k]);
                py[i*ny*nz + j*nz + k] = 1 + sin(ypos[i*ny*nz + j*nz + k] + zpos[i*ny*nz + j*nz + k]);
                pz[i*ny*nz + j*nz + k] = cos(zpos[i*ny*nz + j*nz + k]);

                E[i*ny*nz + j*nz + k] = .5 * (px[i*ny*nz + j*nz + k]*px[i*ny*nz + j*nz + k] + py[i*ny*nz + j*nz + k]*py[i*ny*nz + j*nz + k] + pz[i*ny*nz + j*nz + k]*pz[i*ny*nz + j*nz + k])/rho[i*ny*nz + j*nz + k] + 2;

                ptot[i*ny*nz + j*nz + k] = (2/3)*(E[i*ny*nz + j*nz + k] - .5*(px[i*ny*nz + j*nz + k]*px[i*ny*nz + j*nz + k] + py[i*ny*nz + j*nz + k]*py[i*ny*nz + j*nz + k] + pz[i*ny*nz + j*nz + k]*pz[i*ny*nz + j*nz + k])/rho[i*ny*nz + j*nz + k]);
            }
        }
    }

    //printf("DEBUG LOG 5\n");
    for (i = 0; i < ny; i++) {
        for (j = 0;j < nz; j++) {
            freezespeed[i + nz*j] = 10.0;
        }
    }

    double* lambda = freezespeed + ny*nz;
    *lambda = 0.1;

    double* gamma = lambda + 1;
    *gamma = 5/3;

    double* rhomin = gamma + 1;
    *rhomin = 1e-5;
    //printf("SiZE %d\n", rhomin - h_params);
    printf("SiZE %d\n", size);

    //double *d_params = (double *) gemtcGPUMalloc(size);
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);
    for(j=0; j<NUM_TASKS; j++){
        d_params = (double *) malloc(size);
        if (d_params == NULL) {
            printf("Unable to allocate memory\n");
        }
        for(i=0; i < size/sizeof(double); i++) d_params[i] = h_params[i];
        FluidW(d_params);
        free(d_params);
    }

    //printf("DEBUG LOG 9\n");
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    /* Evaulate time taken for the computation */
    time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

    printf(" Time taken %f seconds\n", time_spent);
    printf("\n");

    free(h_params);
    free(xpos);
    free(ypos);
    free(zpos);
    return 0;
}
