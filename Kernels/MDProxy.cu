__device__ void ComputeParticles(void* params){
  
  void *table = *((void**)params);
  int offset = *((int*)(((void **)params) + 1)); 
  
  //Extract all the values. 
  int np = *((int*) table);
  int nd = *(((int*) table)+1);

  int size = np * nd;

  double *pos = (double*)(((int*) table)+2);
  double *vel = pos + size; 
  double *mass = vel + size; 
  double *f = mass + 1;

  double *pe = f + size;
  double *ke = pe + size;

  double d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];
  
  int i,j;
  int tid = threadIdx.x % 32; 
  int k = offset + tid; 
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
