#include<stdio.h>

__device__ void LCSubstring(void *params){
  char *result = (char *)params + sizeof(char)*14;
  char *m = "test!";
  int i=0;
  while(i<6){
    result[i] = m[i];
    i++;
  }
}
