#include <stdio.h>
#include "sleep.h"


void c_sleep(int i){

  printf("Calling sleep_wrapper\n");
  sleep_wrapper(i);
  printf("End sleep_wrapper\n");

}

