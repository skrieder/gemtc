#include <stdio.h>
#include <unistd.h>
#include "api.h"

void gemtcSetup(){

  printf("In setup.\n");

  // sleep to mimic overhead
  sleep(1);

}

// params are 1. tasktype, threads needed, pointer to task parameters, size of that pointer 
// void *gemtcRun(int Type, int Threads, void *host_params, int size_params){
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
