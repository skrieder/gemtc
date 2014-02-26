#include <stdio.h>
#include "saxpy.h"


int cuda_wrapper(){

  printf("Calling sleep_wrapper\n");
  cuda_saxpy_launcher(1, 1);
  printf("End sleep_wrapper\n");

}

