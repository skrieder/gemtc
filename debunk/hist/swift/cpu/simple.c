#include <stdlib.h>
#include "hist.h"

main() {
  double v[4] = { 1, 2, 3, 10 };
  double *sum = hist(v, 4);
  free(sum);
  
}
