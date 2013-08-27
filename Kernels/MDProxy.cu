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
