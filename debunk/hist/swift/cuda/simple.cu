#include <stdlib.h>
#include "hist.h"

main() {
  double v[1024];
  int i;

  for( i=0; i< 1024; i++)
  {
    v[0] = i % 256;
  }
  double *sum = hist(v, 1024);
  free(sum);
  
}
