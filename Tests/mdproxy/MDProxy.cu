#include "../../gemtc.cu"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv){
  gemtcSetup(25600,0);

  int np = 32; //Modify this variable.
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

  //Table | np | nd | mass | pos[] | vel[] | acc[] |  f[]  | 
  //Bytes | 4  | 4  |   8  | a_mem | a_mem | a_mem | a_mem | 

  int mem_needed = sizeof(int) * 2 + sizeof(double) + a_mem*4; 
  void *d_table = gemtcGPUMalloc(mem_needed); 
  void *h_table = malloc(mem_needed); 

  memcpy( h_table               , &np   , sizeof(int));  
  memcpy( (((int*)h_mem)+1)     , &nd   , sizeof(int)); 
  memcpy( (((double*)h_mem)+1)  , &mass , sizeof(double));

  for(i=0; i<4; i++){
    memcpy( (((double*)h_mem) + (a_size*i) + 2), darray, a_mem); 
  }
  //Copy Table onto Device Memory
  gemtcMemcpyHostToDevice(d_table, h_table, mem_needed);

  
  /////////////// Initialize ////////////////
  
  int init_mem_needed = sizeof(double) + a_mem + sizeof(int) + sizeof(int);

  void *d_init_params = gemtcGPUMalloc(init_mem_needed);
  void *h_init_params = malloc(init_mem_needed);

  //Init Params  | &Table |  box[]  | seed | offset | 
  //Bytes        |   8    |  a_size |  4   |   4    | 

  





  return 1; 
}
