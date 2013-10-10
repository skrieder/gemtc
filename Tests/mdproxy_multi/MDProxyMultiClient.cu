#include "../../gemtc.cu"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>

#define MAX_WORKERS 32 
void safeDump(void* params);
void dumpParams(void* params);
double cpu_time();
void pullJobs(int kernel_calls); 

int main(int argc, char **argv){ //Modify this to take the correct parameters.
  gemtcSetup(100000,0);

  const long int np = 5; //Modify this variable.
  const long int nd = 2; //This value should only be 2 or 3! 
  const double mass = 1.0;
  
  int a_size = np*nd;
  int a_mem = sizeof(double) * a_size; 

  // declare the arrays
  double position[a_size];
  double darray[a_size];
  
  //Here, I am generating the random values for the position table. 
  //SCOTT: We will be able to remove the srand and position[i]... command
  srand(123456789); // set srand  
  int i; // i for the loop
  for(i=0; i<a_size; i++){
    position[i] = ((double)rand())/52000; // randomize the position array
    //printf("setting position[%d]=%f\n", i, position[i]);
    darray[i] = 0.0; // zero out the darray
  }

  printf("LAST_PRINT:%f\n", position[a_size-1]);

  //Setup the Table we will constantly reference.
  //Table | np | nd | mass | pos[] | vel[] | acc[] |  f[]  | pe[]  |  ke[]  |
  //Bytes | 8  | 8  |   8  | a_mem | a_mem | a_mem | a_mem | a_mem | a_mem  |

  int mem_needed = sizeof(long int) * 2 + sizeof(double) + a_mem*6; 
  void *h_table = malloc(mem_needed); 
  void *d_table = gemtcGPUMalloc(mem_needed);

  memcpy( h_table                      , &np   , sizeof(long int));  
  memcpy( (((long int*)h_table)+1)     , &nd   , sizeof(long int)); 
  memcpy( (((double*)h_table)+2)       , &mass , sizeof(double));
  memcpy( (((double*)h_table)+3)       , position, a_mem);

  //DEBUG
  double *test_mass = (((double*) h_table) +2);
  double *test_pos = test_mass + 1;
  for(int j=0;j<10;j++){
    //    printf("test_pos[%d]=%f\n", j,test_pos[j]);
  }
  //END DEBUG


  for(i=1; i<6; i++){
    memcpy( (((double*)h_table) + a_size*i + 3), darray, a_mem); 
  }

  //  safeDump(h_table);
    dumpParams(h_table);

  // copy host table into device
  gemtcMemcpyHostToDevice(d_table, h_table, mem_needed);
  
  //Begin Computation on the GPU.
  double ctime1 = cpu_time(); //Start the Timer.
  
  gemtcPush(20, 32, i*1000, d_table);
  printf("--- Pushed Job ---\n");
  pullJobs(1);   
  printf("--- Received Results ---\n"); 
  
  //Get the Values from the Data Table.
  void *comp_table = malloc(mem_needed);
  gemtcMemcpyDeviceToHost(comp_table, d_table, mem_needed);

  double ctime2 = cpu_time(); //End the Timer. 
  
  //THIS IS THE ARRAY YOU WANT TO RETURN//
  double *pos = ((double*)comp_table) + 3; //get the position array.
  printf("Elapsed Time: %f\n", ctime2-ctime1);

  // dump params
  dumpParams(comp_table);
  
  gemtcCleanup();

  return 0; 
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

void safeDump(void* params){
  printf("===SafeDump===\n");
  long int np = *((long int*) params);
  long int safe_np;
  memcpy((void *)safe_np, params, 8);
  long int nd = *(((long int*) params)+1);
  printf("safe_np = %ld", safe_np);

  printf("NP: %ld\n ND: %ld\n", np, nd);
}

void dumpParams(void* params){
  /*This will dump everything in the data table, but
    you have to actually pass the table here. */

  long int np = *((long int*) params);
  long int nd = *(((long int*) params)+1);

  int size = np * nd;

  double *mass = (((double*) params) +2);
  double *pos = mass + 1;
  double *vel = pos + size;
  double *acc = vel + size;
  double *f = acc + size;

  printf("NP: %ld\n ND: %ld\n", np, nd);

  int i;
  printf("#, pos, vel, acc, f\n");
  for(i=0; i<size; i++){
    printf("%d: %.16f %.2f %.2f %.2f\n", i, pos[i], vel[i], acc[i], f[i]);
  }
}

double cpu_time(){
  struct timeval t;
  gettimeofday(&t, NULL);
  return t.tv_sec + t.tv_usec*1e-6;
}
