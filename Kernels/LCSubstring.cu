#include <stdio.h>

__device__ void LCSubstring(void *params){
 char* output = (char*)params;
 output = "I am the correct message!";
}
