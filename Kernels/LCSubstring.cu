#include <stdio.h>

__device__ void LCSubstring(void *params){  
  char *result = (char*)params+sizeof("abcdef");
  result = "test";  
}
