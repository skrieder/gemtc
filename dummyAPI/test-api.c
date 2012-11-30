#include <stdio.h>
#include "api.c"

int main(){

  // call setup
  gemtcSetup();

  // call run
  gemtcRun();

  // call cleanup
  gemtcCleanup();

}
