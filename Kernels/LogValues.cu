__device__ int LogValues(void *nodes){
  int *new_val = (int *)nodes;
  *new_val = 5;
  return *new_val;
}
