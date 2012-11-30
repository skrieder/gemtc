#include <stdio.h>
#include "api.h"

int main(){

  printf("In main\n");

  gemtcSetup();
  gemtcRun();
  gemtcCleanup();

}

void gemtcSetup(){

  printf("In setup\n");

}

void gemtcRun(){

  printf("In run\n");

}

void gemtcCleanup(){

  printf("In cleanup\n");

}
