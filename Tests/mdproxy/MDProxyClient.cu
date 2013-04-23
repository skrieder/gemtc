#include "../../gemtc.cu"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_WORKERS 32 
int pushJobs(int num_tasks, void *h_params, void *offset_pointer, int mem_needed, int microkernel);
void pullJobs(int kernel_calls); 
double cpu_time();

int main(int argc, char **argv){
  gemtcSetup(100000,0);

  const int np = 50; //Modify this variable.
  const int nd = 2; //This value should only be 2 or 3!
  const int step_num = 1; 
  const int seed = 123456789;
  const double mass = 1.0;
  const double dt = 0.0001;

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

  for(i=0; i<6; i++){
    memcpy( (((double*)h_table) + a_size*i + 2), darray, a_mem); 
  }
  //Copy Table onto Device Memory
  gemtcMemcpyHostToDevice(d_table, h_table, mem_needed);
  
  /////////////// Initialize ////////////////
  
  int init_mem_needed = sizeof(double) + sizeof(double)*nd + sizeof(int); 
  void *h_init_params = malloc(init_mem_needed);

  //Init Params  | &Table |  box[]  | seed |
  //Bytes        |   8    | 8 * nd  |  4   | 

  double box[nd];
  for(i=0; i<nd; i++){
    box[i] = 10.0;
  }

  memcpy( h_init_params                              , &d_table , sizeof(void*));
  memcpy( ((double*)h_init_params)+1                 ,  box     , nd*sizeof(double));
  memcpy( (int*)(((double*)h_init_params)+1+nd)      ,  &seed   , sizeof(int));
   
  void *d_init_params = gemtcGPUMalloc(init_mem_needed);
  gemtcMemcpyHostToDevice(d_init_params, h_init_params, init_mem_needed);

  /*The Init Kernel cannot be parallelized if we want to have same
    results as the .cpp version. As a result, we only call it on 1
    Microkernel */

  gemtcPush(17, 32, 1000, d_init_params); 
  pullJobs(1);   

  /////////////// Compute/Update Loop /////////////////
  printf("\nComputing inital forces and energies.\n");
  
  double e0, ctime1, ctime2;
  int j; 
  int print_step = step_num / 10;
  if(print_step == 0){ print_step++;}; 

  printf("Step\tP Energy\tK Energy\t(P+K-E0)/E0\n");
  for(j=0; j<=step_num; j++){

    //Compute Params  | &Table | offset | 
    //Bytes           |   8    |   4    | 

    int comp_mem_needed = sizeof(void*) + sizeof(int); 
    void *h_comp_params = malloc(comp_mem_needed);

    memcpy(h_comp_params, &d_table, sizeof(void*));

    void *comp_offset_pointer = ((double*)h_comp_params) + 1; 
   
    //Push the Jobs 
    int k_calls = pushJobs(np, h_comp_params, comp_offset_pointer, comp_mem_needed, 16);
    pullJobs(k_calls);   
    
    void *comp_table = malloc(mem_needed);

    //Get the Values from the Data Table. 
    gemtcMemcpyDeviceToHost(comp_table, d_table, mem_needed);

    double *pe = ((double*)comp_table) + 2 + 4 * a_size;
    double *ke = pe + a_size;

    for(i=0; i<a_size; i++){
      printf("%d: %f %f\n", i, pe[i], ke[i]);
    }
    
    double psum = 0.0;
    double ksum = 0.0; 
    
    for(i=0; i < a_size; i++){
      psum += pe[i];
      ksum += ke[i];
    }
   
    if(j == 0){
      e0 = psum + ksum; 
      printf("%d\t%.2f\t\t%.4f\t\t%f\n", j, psum, ksum, (psum+ksum-e0)/e0);
      ctime1 = cpu_time();
      continue;
    }

    if( j % print_step == 0){
      printf("%d\t%.2f\t\t%f\t\t%f\n", j, psum, ksum, (psum+ksum-e0)/e0);  
    }

    ////////////////UPDATE/////////////////

    //Update Params | &Table |  dt | offset |
    //Bytes         |   8    |  8  |   4    |

    int upda_mem_needed = sizeof(void*) + sizeof(double) + sizeof(int);

    void *h_upda_params = malloc(upda_mem_needed); 
    memcpy(h_upda_params               , &d_table, sizeof(void*));
    memcpy(((double*)h_upda_params) + 1,   &dt   , sizeof(double));
    
    void *upda_offset_pointer = ((double*)h_upda_params) + 2; 

    k_calls = pushJobs(np, h_upda_params, upda_offset_pointer, upda_mem_needed, 18);
    pullJobs(k_calls);
  }

  ctime2 = cpu_time();
  printf("Elapsed cpu time for main computation: %.2f\n", ctime2-ctime1);
  
  gemtcCleanup(); 
  return 0; 
}

int pushJobs(int num_tasks, void *h_params, void *offset_pointer, int mem_needed, int microkernel){
  int kernel_calls = num_tasks / MAX_WORKERS; 
  int i;

  for(i=0; i<= kernel_calls; i++){
    int offset = i * MAX_WORKERS; 
    int threads = (offset + MAX_WORKERS <= num_tasks) ? MAX_WORKERS : num_tasks-offset;  
    
    if(threads > 0){
      //Allocate device memory for params. 
      void *d_params = gemtcGPUMalloc(mem_needed);
      //Copy the offset into parameters.
      memcpy(offset_pointer, &offset , sizeof(int));
      //Copy params to device. 
      gemtcMemcpyHostToDevice(d_params, h_params, mem_needed); 
      //Push Job 
      printf("gemtcPush(%d, %d, %d, d_params);\n", microkernel, threads, i*1000); 
      gemtcPush(microkernel, threads, i*1000, d_params); 
    }
  }

  return kernel_calls; 
}

void pullJobs(int kernel_calls){
  int i; 
  for(i=0; i<kernel_calls; i++){ //Pulls for jobs. 
    void *ret = NULL;
    int id;

    while(ret==NULL){
      gemtcPoll(&id, &ret);
    } 
  }
}

double cpu_time(){
  double value = (double)clock() / (double)CLOCKS_PER_SEC;
  return value;
}
