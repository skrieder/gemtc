#include <stdio.h>
#include "saxpy.h"


int c_saxpy(int num_elements, int num_threads){

  printf("Calling sleep_wrapper\n");
  cuda_saxpy_launcher(num_elements, num_threads);
  printf("End sleep_wrapper\n");

  return 0;
}
