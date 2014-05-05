#include "MDProxy.c"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <string.h>
#include "g.h"

void saxpy(int n, float a, float *x, float *y)
{
  int i;
  for (i = 0; i < n; ++i)
    y[i] = a*x[i] + y[i];
}

int g(int i1, int i2)
{
  int sum = i1+i2;
  printf("g: %i+%i=%i\n", i1, i2, sum);
  printf("sleeping for %i seconds...\n", sum);
  sleep(sum);
}
