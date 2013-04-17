////// The intention of this program is used 
////// to keep all my test fragments for MD Proxy, do not try to compile.


void InitTestFrag(){ 
  void *check_table = *((void**)params);
  void *table = malloc(mem_needed); //We have to allocate for the whole table..
  gemtcMemcpyDeviceToHost(table, check_table, mem_needed); 

  int *p_np = (int*)(table);
  int *p_nd = p_np + 1;

  int size = (*p_np) * (*p_nd);

  double *pos = ((double*)(table)) + 1;
  double *vel = pos + size;
  double *acc = vel + size; 

  double *p_box = (double*)(((void**)params)+1);
  int *p_seed = (int*)(p_box + nd);
  int *p_offset = p_seed + 1;   

  printf("%d %d %d %d\n", *p_np, *p_nd, *p_seed, *p_offset);
  printf("%f %f\n", p_box[0], p_box[1]); 

  for(i=0; i<a_size; i++){
    printf("%f %f %f\n", pos[i], vel[i], acc[i]);
  }
}
