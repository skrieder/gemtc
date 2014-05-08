#include <stdlib.h>
#include "hist.h"

main() {
  double v[10000];
  int i;
  int TEST =1;
  for( i=0; i< 10000; i++)
  {
    v[0] = i % 256;
  }
  for(i=0;i<TEST;i++){
  	double *sum = hist(v, 10000);
  	free(sum);
  }
}
