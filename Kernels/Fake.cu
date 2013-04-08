__device__ void Fake(void *params){
  int *np = (int*)params;
  int *nb = np + 1;

  int size = (*np) * (*nb); 

  double *pos = (double *)(np + 2);
  *np = 15;
  *nb = 68;
  
  int i;
  for(i=0; i<size; i++){
    pos[i] = i; 
  }
}
