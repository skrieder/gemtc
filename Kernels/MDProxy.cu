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

  int i, j;

  double d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];

  //CUDA Threads
  int warp_size = 32;
  int tid = threadIdx.x%warp_size;
 
  //Compute all the potential energy and forces.
  //for(k=0; k<np; k++){
  while(tid<np){
    for(i=0; i<nd; i++){
      f[i+tid*nd] = 0.0;
    }
    
    for(j=0; j<np; j++){
      if(tid == j){ continue; }
      
      d = 0.0; 
      for(i=0; i<nd; i++){
	rij[i] = pos[tid*nd+i] - pos[j*nd+i];
	d += pow(rij[i], 2); 
      }
      
      d = sqrt(d); 
      d2 = d < PI2? d : PI2; 
      
      pe[tid] +=  0.5 * pow(sin(d2), 2);
      
      for(i=0; i<nd; i++){
	f[i+tid*nd] = f[i+tid*nd] - rij[i] *sin(1.0 * d2) / d;
      }
    }
    tid += warp_size;
  }

  int tid2 = threadIdx.x%warp_size;
  //  for(k=0;k<np;k++){
  while(tid<np){
    // compute kinetic
    for(i=0; i<nd; i++){
      ke[tid2] += vel[i+tid2*nd] * vel[i+tid2*nd];
    }
    ke[tid2] *= 0.5 * (*mass);
    tid2 += warp_size;
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
