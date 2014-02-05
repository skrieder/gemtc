#include <string.h>
#include <stdlib.h>
#include <time.h>

void saxpy(int n, float a, float *x, float *y)
{
  for (int i = 0; i < n; ++i)
    y[i] = a*x[i] + y[i];
}

void populateRandomFloatArray(int n, float *x){
  for(int i = 0; i <n; i++){
    float r = (float)(rand() % 100);
    x[i] = r;
  }
}
