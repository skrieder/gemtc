#include "kernels.h"

#pragma offload_attribute(push, target (mic))

void MD_ComputeParticles(void* params){  
  printf("MD_ComputeParticles: Params: %p", params);
  return; 
  //Params| &table | offset | 
  //Bytes |   8    |   4    | 
  
 void *table = *((void**)params);
 int offset = *((int*)(((void**)params)+1));
  
  //Extract all the values. 
  int np = *((int*) table);
  int nd = *(((int*) table)+1);

  int size = np * nd;

  double *mass = (double*)(((int*)table)+2);
  double *pos = mass + 1;
  double *vel = pos + size; 
  double *acc = vel + size;
  double *f = acc + size;

  double *pe = f + size;
  double *ke = pe + size;

  int i, j;

  double d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];
 
  // int tid = threadIdx.x % 32; 
  int k; // = offset + tid; 

  for ( k = 0; k < np; k++ ) {
  //Compute all the potential energy and forces.
      for(i=0; i<nd; i++){
        f[i+(k+offset)*nd] = 0.0;
      }
     
      for(j=0; j<np; j++){
        if(k == j){ continue; }

        d = 0.0; 
        for(i=0; i<nd; i++){
          rij[i] = pos[(k+offset)*nd+i] - pos[(j+offset)*nd+i];
          d += pow(rij[i], 2); 
          d = rij[i];
        }

        d = sqrt(d); 
        d2 = d < PI2? d : PI2; 

        pe[k+offset] +=  0.5 * pow(sin(d2), 2);
        
        for(i=0; i<nd; i++){
          f[i+(k+offset)*nd] -= rij[i] * sin(2.0 * d2) / d;
        }
      }

      for(i=0; i < nd; i++){
        ke[(k+offset)] += vel[i+(k+offset)*nd] * vel[i+(k+offset)*nd];
      }

    ke[k+offset] *= 0.5 * (*mass);
  }
}

double r8_uniform_01(int *seed){
  int k; 
  double r;

  k = *seed/ 127773;
  *seed = 16807 * (*seed - k * 127773) - k * 2836;

  if( *seed < 0 ){
    *seed += 2147483647;
  }

  r = (double)(*seed) * 4.656612875E-10;
  return r; 
}

void MD_InitParticles(void* params){
  printf("MD_InitParticles: Params: %p\n", params);
 // return; 
  
  //Params| &table | box[] | seed |
  //Bytes |   8    | 8*nd  |  4   |
  
  void *table = *((void**)params); 

  //Unpack Table  
  int np = *((int*)table);
  int nd = *(((int*)table) + 1);
  double *pos = ((double*)table) + 2;
 
  //Unpack Params
  double *box = (double*)(((void**)params)+1);
  int *seed = (int*)(box + nd);

  int i,j; 
  //Update values
  for ( j = 0; j < np ; j++){
    for ( i = 0; i < nd ; i++){
      printf("MD_InitParticles: Writting to pos @ i=%d, j=%d, nd=%d: %d", i, j, nd, i+j*nd);
      pos[i+j*nd] = box[i] * r8_uniform_01(seed);
    }
  }
}

void MD_UpdatePosVelAccel(void* params){
  printf("MD_UpdatePosVelAccel: Params: %p", params);
  return;
 
  //Params: | &table |  dt  | offset | 
  //Bytes:  |    8   |   8  |   4    |

  void *table = *((void**)params);
  double dt = *((double*)(((void**)params)+1));
  int offset = *(((int*)params) + 4);
  
  //Unpack Table
  int np = *((int*)table);
  int nd = *(((int*)table) + 1);
  
  int size = np * nd;

  double mass = *(((double*)table) + 1); 
   
  double *pos = ((double*)table) + 2;
  double *vel = pos + size;
  double *acc = vel + size; 
  double *f = acc + size; 
  double *pe = f + size;
  double *ke = pe + size; 
  
  int i,j;
  double rmass = 1.0 / mass;
  int index;
  for ( j = 0; j < np; j++ ) {
	  for ( i = 0 ; i < nd; i ++) {
	  	index = (j + offset)*nd + i;

	    pos[index] += vel[index] * dt + 0.5 * acc[index] * dt * dt;   
	    vel[index] += 0.5 * dt * (f[index] * rmass + acc[index]);
	    acc[index] = f[index] * rmass;
	    
	    pe[index] = 0.0;
	    ke[index] = 0.0;
	  }
	}
}



#pragma offload_attribute(pop)
