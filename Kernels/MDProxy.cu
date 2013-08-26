///////////////////////////////////////////////////
//////////// Data Table Helpers ///////////////////
///////////////////////////////////////////////////

typedef struct 
{
  int np, nd;
  double *mass;
  double *pos, *vel, *acc, *f, *pe, *ke;
}Table;

__device__ Table Unpack_Table(void *params){
  
  Table data; 

  data.np = *((int*) params);
  data.nd = *(((int*) params)+1);

  int size = data.np * data.nd;

  data.mass = (double*)(((int*)params)+2);
  data.pos = data.mass + 1;
  data.vel = data.pos + size;
  data.acc = data.vel + size;
  data.f = data.acc + size;

  data.pe = data.f + size;
  data.ke = data.pe + size;

  return data;
}

///////////////////////////////////////////////////
//////////// Single Node Kernels ///////////////////
////////////////////////////////////////////////////
__device__ void ComputeParticles(void* params){  
  
  //Params| &table | offset | 
  //Bytes |   8    |   4    | 

  void *table = *((void**)params);
  Table dt = Unpack_Table(table);

  int offset = *((int*)(((void**)params)+1));

  int i, j;
  double d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];

  int tid = threadIdx.x % 32; 
  int k = offset + tid; 
  //Compute all the potential energy and forces.
  for(i=0; i<dt.nd; i++){
    dt.f[i+k*dt.nd] = 0.0;
  }

  for(j=0; j<dt.np; j++){
    if(k == j){ continue; }

    d = 0.0; 
    for(i=0; i<dt.nd; i++){
      rij[i] = dt.pos[k*dt.nd+i] - dt.pos[j*dt.nd+i];
      d += pow(rij[i], 2); 
      d = rij[i];
    }

    d = sqrt(d); 
    d2 = d < PI2? d : PI2; 

    dt.pe[k] +=  0.5 * pow(sin(d2), 2);
    
    for(i=0; i<dt.nd; i++){
      dt.f[i+k*dt.nd] -= rij[i] * sin(2.0 * d2) / d;
    }
  }

  for(i=0; i < dt.nd; i++){
    dt.ke[k] += dt.vel[i+k*dt.nd] * dt.vel[i+k*dt.nd];
  }

  dt.ke[k] *= 0.5 * (*dt.mass);
}

__device__ double r8_uniform_01(int *seed){

  int k = *seed/ 127773;
  *seed = 16807 * (*seed - k * 127773) - k * 2836;

  if( *seed < 0 ){
    *seed += 2147483647;
  }

  return (double)(*seed) * 4.656612875E-10; 
}

__device__ void InitParticles(void* params){
  
  //Params| &table | box[] | seed |
  //Bytes |   8    | 8*nd  |  4   |
  
  void *table = *((void**)params);
  Table dt = Unpack_Table(table); 

  //Unpack Params
  double *box = (double*)(((void**)params)+1);
  int *seed = (int*)(box + dt.nd);

  int i,j; 
  //Update values
  for ( j = 0; j < dt.np ; j++){
    for ( i = 0; i < dt.nd ; i++){
      dt.pos[i+j*dt.nd] = box[i] * r8_uniform_01(seed);
    }
  }
}

__device__ void UpdatePosVelAccel(void* params){
 
  //Params: | &table |  dt  | offset | 
  //Bytes:  |    8   |   8  |   4    |

  void *table = *((void**)params);
  Table t = Unpack_Table(table);

  double dt = *((double*)(((void**)params)+1));
  int offset = *(((int*)params) + 4);
  
  int i,j;
  double rmass = 1.0 / (*t.mass);

  int tid = threadIdx.x % 32;
  j = offset + tid; 

  //Begin computation
  for ( i = 0 ; i < t.nd; i ++){
    t.pos[i+j*t.nd] += t.vel[i+j*t.nd] * dt + 0.5 * t.acc[i+j*t.nd] * dt * dt;   
    t.vel[i+j*t.nd] += 0.5 * dt * (t.f[i+j*t.nd] * rmass + t.acc[i+j*t.nd]);
    t.acc[i+j*t.nd] = t.f[i+j*t.nd] * rmass;
    
    t.pe[i+j*t.nd] = 0.0;
    t.ke[i+j*t.nd] = 0.0;
  }
}

///////////////////////////////////////////////////
//////////// Multi-Node Kernels ///////////////////
///////////////////////////////////////////////////

__device__ void ComputeParticles_Multi(void* params){  
  
  //Extract all the values. 
  long int np = *((long int*) params);
  long int nd = *(((long int*) params)+1);

  int size = np * nd;

  double *mass = (((double*) params)+2);
  double *pos = mass + 1;
  double *vel = pos + size; 
  double *acc = vel + size;
  double *f = acc + size;
  double *pe = f + size;
  double *ke = pe + size;

  int i, j, k;

  double d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];
 
  //Compute all the potential energy and forces.
   for(k=0; k<np; k++){
      for(i=0; i<nd; i++){
        f[i+k*nd] = 0.0;
      }
     
      for(j=0; j<np; j++){
        if(k == j){ continue; }

        d = 0.0; 
        for(i=0; i<nd; i++){
          rij[i] = pos[k*nd+i] - pos[j*nd+i];
          d += pow(rij[i], 2); 
        }

        d = sqrt(d); 
        d2 = d < PI2? d : PI2; 

        pe[k] +=  0.5 * pow(sin(d2), 2);
        
        for(i=0; i<nd; i++){
          f[i+k*nd] = f[i+k*nd] - rij[i] *sin(1.0 * d2) / d;
        }
      }
   }
   for(k=0;k<np;k++){
     // compute kinetic
     for(i=0; i<nd; i++){
       ke[k] += vel[i+k*nd] * vel[i+k*nd];
     }
     ke[k] *= 0.5 * (*mass);
   }	
}
__device__ void UpdatePosVelAccel_Multi(void* params){
  
  //Unpack Table
  long int np = *((long int*)params);
  long int nd = *(((long int*)params) + 1);
  
  int size = np * nd;

  double mass = *(((double*)params) + 2); 
   
  double *pos = ((double*)params) + 3;
  double *vel = pos + size;
  double *acc = vel + size; 
  double *f = acc + size;  
  double dt = .0001; 
  int i,j;
  double rmass = 1.0 / mass;

  //O(np*nd)
  //Begin computation
  for(j=0; j<np; j++){
    for ( i = 0 ; i < nd; i ++){
      pos[i+j*nd] += vel[i+j*nd] * dt + 0.5 * acc[i+j*nd] * dt * dt;   
      vel[i+j*nd] += 0.5 * dt * (f[i+j*nd] * rmass + acc[i+j*nd]);
      acc[i+j*nd] = f[i+j*nd] * rmass;
    }
  }
}

__device__ void MDProxy(void* params){
  ComputeParticles_Multi(params);
  UpdatePosVelAccel_Multi(params);
}
