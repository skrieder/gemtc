__device__ void ComputeParticles(void* params){  
  //Extract all the values. 
  int np = *((int*) params);
  int nd = *(((int*) params)+1);

  int size = np * nd;

  double *mass = (double*)(((int*)params)+2);
  double *pos = mass + 1;
  double *vel = pos + size; 
  double *f = vel + size;

  double *pe = f + size;
  double *ke = pe + size;
  
  double d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];
  
  int i,j;
  int tid = threadIdx.x % 32; 
  //int k = offset + tid; 
  int k = tid;
  //Compute all the potential energy and forces.
      for(i=0; i<nd; i++){
        f[i+k*nd] = 0.0;
      }

      for(j=0; j<np; j++){
        if(k == j){ continue; }

        d = 0.0; 
        for(i=0; i<nd; i++){
          rij[i] = pos[k*nd+i] - pos[j*nd+i];
          d += pow(rij[i], 2); 
          d = rij[i];
        }

        d = sqrt(d); 
        d2 = d < PI2? d : PI2; 

        pe[k] +=  0.5 * pow(sin(d2), 2);
        
        for(i=0; i<nd; i++){
          f[i+k*nd] -= rij[i] * sin(2.0 * d2) / d;
        }
      }

      for(i=0; i < nd; i++){
        ke[k] += vel[i+k*nd] * vel[i+k*nd];
      }

      ke[k] *= 0.5 * (*mass);
}

__device__ double r8_uniform_01(int *seed){
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

__device__ void InitParticles(void* params){
  
  //Params| &table | box[] | seed | offset |  
  //Bytes |   8    | 8*nd  |  4   |   4    |
  
  void *table = *((void**)params); 

  //Unpack Table  
  int np = *((int*)table);
  int nd = *(((int*)table) + 1);
  
  int size = np * nd;

  double *pos = ((double*)table) + 1;
  double *vel = pos + size;
  double *acc = vel + size; 

  //Unpack Params
  double *box = (double*)(((void**)params)+1);
  int *seed = (int*)(box + nd);
  //int *offset = seed + 1; 

  int i,j; 
  //int tid = (threadIdx.x % 32) + *offset; 
  //Update values
  for ( j = 0; j < np ; j++){
    for ( i = 0; i < nd ; i++){
      pos[i+j*nd] = box[i] * r8_uniform_01(seed);
      vel[i+j*nd] = 0.0;
      acc[i+j*nd] = 0.0;
    }
  }

}

__device__ void UpdatePosVelAccel(void* params){
 
  //Params: | np | nd |  *pos  |  *vel  |   *f   |  *acc  | mass | dt | 
  //Bytes:  | 4  | 4  | 8*size | 8*size | 8*size | 8*size |  8   |  8 | 

  //Extract Values 
  int np = *((int*)params);
  int nd = *(((int*)params)+1);

  int size = np * nd; 

  double *pos = ((double*)(params) + 1);
  double *vel = pos + size; 
  double *f = vel + size;
  double *acc = f + size;

  double mass = *(acc + size);
  double dt = *(acc + size + 1); 
  
  int i,j; 
  double rmass = 1.0 / mass;

  //Begin computation
  for ( j = 0; j < np ; j++){
    for ( i = 0 ; i < nd; i ++){
      pos[i+j*nd] += vel[i+j*nd] * dt + 0.5 * acc[i+j*nd] * dt * dt;   
      vel[i+j*nd] += 0.5 * dt * (f[i+j*nd] * rmass + acc[i+j*nd]);
      acc[i+j*nd] = f[i+j*nd] * rmass; 

    }
  }
}
