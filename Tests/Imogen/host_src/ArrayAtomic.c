/*
 * Imogen Host code for benchmarking ArrayAtomic
 */
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<unistd.h> 
#include<limits.h>
#include<stdlib.h>

void ArraySetMin(int n, double min, double* d_params)
{
    int i = 0;

    while (i < n) {
        if (d_params[i] < min) {
            d_params[i] = min;
        }
        i++;
    }
    return;
}

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, ARRAY_SIZE;

  struct timespec start, end;
  double time_spent =0.0;
  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    ARRAY_SIZE = atoi(argv[2]);
  }else{
    printf("This test requires two parameters:\n");
    printf("   int NUM_TASKS, int ARRAY_SIZE\n");
    printf("where  NUM_TASKS is the total numer of tasks\n");
    printf("       ARRAY_SIZE is the side length of the array\n");
    exit(1);
  }

  int i, j;
  double *h_params = (double *) malloc(sizeof(double)*(ARRAY_SIZE));

  /*
   * Minimum threshold
   */
  for(j=0; j<ARRAY_SIZE; j++){
    h_params[j]= ((double) rand())/INT_MAX;
  }

  /*
   * Purposefully set 1 array parameters to be lessa then minimum
   */
  h_params[3] = .009;
  printf("Minimum Threshold %f\n", h_params[1]);
  //printf("ORIGINAL ARRAY \n");
  //for(j=0; j<ARRAY_SIZE; j++) {
  //  printf("Element %f\n", h_params[j]);
  //}
  printf("\n");
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  double *d_params = NULL;
  for(j=0; j<NUM_TASKS; j++){
      d_params = (double *) malloc(sizeof(double)*(ARRAY_SIZE));
      for(i=0; i < ARRAY_SIZE; i++) d_params[i] = h_params[i];
      ArraySetMin(ARRAY_SIZE, 0.053, d_params); 
      free(d_params);
  }
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  /* Evaulate time taken for the computation */
  time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

  printf(" Time taken %f seconds\n", time_spent);
  printf("\n");
  free(h_params);
  return 0;
}
