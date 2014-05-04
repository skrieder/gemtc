#include "MDProxy.c"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <string.h>
#include "g.h"

int g(int i1, int i2)
{
  int sum = i1+i2;
  printf("g: %i+%i=%i\n", i1, i2, sum);
  printf("sleeping for %i seconds...\n", sum);
  sleep(sum);
}

int mdproxy_wrapper(long int np, long int nd, double mass){ //Modify this to take the correct parameters.
  /*
  if(argc!=4){
    printf("Usage: \n\t%s <int num_particles> <int num_dimensions> <double mass>\n", argv[0]);
    printf("Example: %s 5 3 1.1\n", argv[0]);
    return 1;
  }

  const long int np = atoi(argv[1]); //Modify this variable.
  const long int nd = atoi(argv[2]); //This value should only be 2 or 3! 
  const double mass = atoi(argv[3]);
  */  
  printf("NP = %ld, ND = %ld, MASS = %f\n", np, nd, mass);
  
  nd = 3;

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

  //  printf("LAST_PRINT:%f\n", position[a_size-1]);

  //Setup the Table we will constantly reference.
  //Table | np | nd | mass | pos[] | vel[] | acc[] |  f[]  | pe[]  |  ke[]  |
  //Bytes | 8  | 8  |   8  | a_mem | a_mem | a_mem | a_mem | a_mem | a_mem  |

  int mem_needed = sizeof(long int) * 2 + sizeof(double) + a_mem*6; 
  void *h_table = malloc(mem_needed); 
  //  void *d_table = gemtcGPUMalloc(mem_needed);
  
  memcpy( h_table                      , &np   , sizeof(long int));  
  memcpy( (((long int*)h_table)+1)     , &nd   , sizeof(long int)); 
  memcpy( (((double*)h_table)+2)       , &mass , sizeof(double));
  memcpy( (((double*)h_table)+3)       , position, a_mem);

  //DEBUG
  double *test_mass = (((double*) h_table) +2);
  double *test_pos = test_mass + 1;
  int j;
  //  for(j=0;j<a_size;j++){
  //  printf("test_pos[%d]=%f\n", j,test_pos[j]);
  //}

  //  safeDump(h_table);
  //dumpParams(h_table);
  
  // copy host table into device
  //gemtcMemcpyHostToDevice(d_table, h_table, mem_needed);
  
  //Begin Computation on the GPU.
  //  double ctime1 = cpu_time(); //Start the Timer.
 
  printf("Calling MD\n");
  // Call MDProxy
  MDProxy(h_table);

  //  dumpParams(h_table);

  /* 
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
*/
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

  printf("NP: %ld\nND: %ld\n", np, nd);

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
