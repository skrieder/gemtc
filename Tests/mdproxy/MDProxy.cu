#include "../../gemtc.cu"
#include <stdio.h>
#include <stdlib.h>

int pushJobs(int num_tasks, int max_workers, void *params, int microkernel); 

int main(int argc, char **argv){
  gemtcSetup(100000,0);

  int np = 10; //Modify this variable.
  int nd = 2; //This value should only be 2 or 3!
  const double mass = 1.0;

  int a_size = np*nd;
  int a_mem = sizeof(double) * a_size; 

  double darray[a_size];
  
  int i; 
  for(i=0; i<a_size; i++){
    darray[i] = 0.0; 
  }
 
  //Setup the Table we will constantly reference.

  //Table | np | nd | mass | pos[] | vel[] | acc[] |  f[]  | pe[]  |  ke[]  |
  //Bytes | 4  | 4  |   8  | a_mem | a_mem | a_mem | a_mem | a_mem | a_mem  |

  int mem_needed = sizeof(int) * 2 + sizeof(double) + a_mem*6; 
  void *d_table = gemtcGPUMalloc(mem_needed); 
  void *h_table = malloc(mem_needed); 

  memcpy( h_table                 , &np   , sizeof(int));  
  memcpy( (((int*)h_table)+1)     , &nd   , sizeof(int)); 
  memcpy( (((double*)h_table)+1)  , &mass , sizeof(double));

  for(i=0; i<4; i++){
    memcpy( (((double*)h_table) + a_size*i + 2), darray, a_mem); 
  }
  //Copy Table onto Device Memory
  gemtcMemcpyHostToDevice(d_table, h_table, mem_needed);
  
  /////////////// Initialize ////////////////
  
  int init_mem_needed = sizeof(double) + a_mem + sizeof(int) + sizeof(int);

  void *d_init_params = gemtcGPUMalloc(init_mem_needed);
  void *h_init_params = malloc(init_mem_needed);

  //Init Params  | &Table |  box[]  | seed | offset | 
  //Bytes        |   8    |  a_size |  4   |   4    | 

  int seed = 107;
  int offset = 99;

  double box[nd];
  for(i=0; i<nd; i++){
    box[i] = 10.0;
  }

  memcpy( h_init_params                              , &d_table , sizeof(void*));
  memcpy( ((double*)h_init_params)+1                 ,  box     , nd*sizeof(double));
  memcpy( (int*)(((double*)h_init_params)+1+a_size)  ,  &seed   , sizeof(int));
  memcpy( ((int*)h_init_params) + 2 + 2*a_size + 1   ,  &offset , sizeof(int)); 

  //Copy Parameters 
  gemtcMemcpyHostToDevice(d_init_params, h_init_params, init_mem_needed);
  
  //Run Init Job
  gemtcPush(20, 32, 12000, d_init_params);

  void *ret = NULL;
  int id; 
  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }
 
  void *params = malloc(init_mem_needed);
  gemtcMemcpyDeviceToHost(params, ret, init_mem_needed);

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
  int *p_seed = (int*)(box + nd);
  int *p_offset = p_seed + 1;   

  printf("%d %d %d %d\n", *p_np, *p_nd, *p_seed, *p_offset);

  return 1; 
}


/*
int pushJobs(int num_tasks, int max_workers, void *params, int microkernel){
  int kernel_calls = num_tasks / max_workers; 
  int i; 

  for(i=0; i<= kernel_calls; i++){
    int offset = i * max_workers; 
    int threads = (offset + max_workers <= num_tasks) ? max_workers : num_tasks-offset;  
    
    if(threads > 0){
      printf("gemtcPush(%d, %d, %d, params);\n", microkernel, threads, (i+microkernel));
    }

  }

  return kernel_calls; 
}
*/

