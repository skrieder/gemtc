#include <stdio.h>
#include <unistd.h>
#include "api.h"

void gemtcSetup(){

  printf("In setup.\n");

  // sleep to mimic overhead
  sleep(1);

}

void gemtcRun(){

  printf("In run.\n");

  // sleep to mimic overhead
  sleep(1);

}

void gemtcCleanup(){

  printf("In cleanup.\n");
  
  // sleep to mimic overhead
  sleep(3);

}
