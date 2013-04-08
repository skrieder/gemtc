__device__ void Fake(void *params){
  int *np = (int*)params;
  int *nb = np + 1;

  *np = 15;
  *nb = 68;
}
