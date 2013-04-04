#include <stdio.h>

__device__ void LCSubstring(void *params){
  char* output = (char*)params;
  char *string = "New message!!";
  int i=0;
  while(i<14){
    output[i]=string[i];
    i++;
  }
}
