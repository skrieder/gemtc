__device__ void* compute(void* params){
  //Extract all the values. 
  int np = *((int*) params);
  int nd = *(np + 1); 

  int size = np * nd;

  double *pos = nd + 1;
  double *vel = pos + size; 

  double mass = *(vel + size); 

  double *f = mass + 1;

  double pot = *(f + size);
  double kin = *(pot + 1);

  double ke, pe, d, d2; 
  double PI2 = 3.141592653589793 / 2.0;
  double rij[3];
  int i,j,k;

  for(k=0; k<np; k++){
    //Compute all the potential energy and forces.
      for(i=0; i<nd; i++){
        f[i+k*nd] = 0.0;
      }

      for(j=0; j<np; j++){
        if(k == j){ continue };

        d = dist( nd, pos+k*nd, pos+j*nd, rij);
        
        if( d < PI2){
          d2 = d; 
        }
        else{
          d2 = PI2;
        }

        pe = pe + 0.5 * pow( sin (d2), 2);
        
        for(i=0; i<nd; i++){
          f[i+k*nd] -= rij[i] * sin(2.0 * d2) / d;
        }
      }

      for(i=0; i < nd; i++){
        ke += vel[i+k*ned] * vel[i+k*nd];
      }
  }

  ke *= 0.5 * mass;
  //*pot = pe;
  //*kin = ke;
}
