/*
 * Imogen Host code for benchmarking freezeAndPtot
 */
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<unistd.h> 
#include<limits.h>
#include<stdlib.h>
#include<math.h>

#define BLOCKDIM 32
#define MAXPOW   5

#define ALFVEN_FACTOR 1

/*
 * Function for FreezeSpeed_hydro
 */
void FreezeSpeed_hydro(void* params)
{
    double locBloc[BLOCKDIM];

    double gammafunc[6];
    int tid = 0, i, j;

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

    for(i = 0; i < ny; i++) {
        for(j = 0; j < nz; j++) { 
          for(tid = 0; tid < 32; tid++) { 
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
    }
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
        printf("where  NUM_TASKS is the total numer of tasks\n");
        printf("SIMULATION_TYPE 1 for 12*12*12 size simulation, 2 for 128*124*119 size simulation; 3 for 333*69*100 size simulation\n");
        exit(1);
    }

    //printf("DEBUG LOG 1\n");

    int i, j, k;
    int size, output_start, output_len;

    switch(SIMULATION_TYPE) {
        case 1:
            size = 5*sizeof(double) + (12*12*12)*6*sizeof(double) + (12*12)*sizeof(double);
            output_start = 5 + (12*12*12)*5;
            output_len = (12*12*12)*sizeof(double) + (12*12)*sizeof(double);
            break;
        case 2:
            size = 5*sizeof(double) + (128*124*119)*6*sizeof(double)  + (124*119)*sizeof(double);
            output_start = 5 + (128*124*119)*5;
            output_len = (128*124*119)*sizeof(double) + (124*119)*sizeof(double);
            break;
        case 3:
            size = 5*sizeof(double) + (333*69*100)*6*sizeof(double) +  (69*100)*sizeof(double);
            output_start = 5 + (333*69*100)*5;
            output_len = (333*69*100)*sizeof(double) + (69*100)*sizeof(double);
            break;
        default:
            size = 5*sizeof(double) + (12*12*12)*6*sizeof(double) + (12*12)*sizeof(double);
            output_start = 5 + (12*12*12)*5;
            output_len = (12*12*12)*sizeof(double) + (12*12)*sizeof(double);
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

    double* gamma = ptot + (nx*ny*nz);
    *gamma = 5/3;

    double* cs0 = gamma + 1;
    double var = 1e-5;
    *cs0 = sqrt((5/3)*pow(var, 2/3));

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
        FreezeSpeed_hydro(d_params);
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
