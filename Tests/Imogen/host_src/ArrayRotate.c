/*
 * Imogen Host code for benchmarking ArrayRotate
 */
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<unistd.h> 
#include<limits.h>
#include<stdlib.h>

void ArrayRotate(int n, double *d_params)
{
    int i, j, temp;
    for(i = 0; i < n; i++)
    {
        for(j = i+1; j < n; j++) {
            temp = d_params[i*n + j];
            d_params[i*n+j] = d_params[j*n+i];
            d_params[j*n+i] = temp;
        }
    }
    return;
}

int main(int argc, char **argv){
  int NUM_TASKS, LOOP_SIZE, MATRIX_SIZE;

  struct timespec start, end;
  double time_spent =0.0;
  if(argc>2){
    NUM_TASKS = atoi(argv[1]);
    MATRIX_SIZE = atoi(argv[2]);
  }else{
    printf("This test requires two parameters:\n");
    printf("   int NUM_TASKS, int MATRIX_SIZE\n");
    printf("where  NUM_TASKS is the total numer of vector add tasks to be sent to gemtc\n");
    printf("       MATRIX_SIZE is the side length of the matrix that is going to be squared\n");
    exit(1);
  }

  int i, j;
  double *h_params = (double *) malloc(sizeof(double)*(MATRIX_SIZE*MATRIX_SIZE));

  for(j=0; j<MATRIX_SIZE*MATRIX_SIZE; j++){
    h_params[j]= ((double) rand())/INT_MAX;
  }

  //printf("ORIGINAL ARRAY \n");
  //for(j=3; j<(MATRIX_SIZE*MATRIX_SIZE+3); j++) {
  //  if (((j - 3) % MATRIX_SIZE) == 0)
  //    printf("\n");
  //  printf(" %f", h_params[j]);
  //}
  //printf("\nBEGINING");

  double* d_params = NULL;
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);
  for(j=0; j<NUM_TASKS; j++){
      d_params = (double *) malloc(sizeof(double)*(MATRIX_SIZE*MATRIX_SIZE));
      for(i=0; i < MATRIX_SIZE*MATRIX_SIZE;  i++) d_params[i] = h_params[i];
      ArrayRotate(MATRIX_SIZE, d_params);
      free(d_params); 
  }
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  /* Evaulate time taken for the computation */
  time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

  printf(" Time taken %f seconds\n", time_spent);
  printf("\n");
  //printf("NEW ARRAY \n");
  //for(j=3+MATRIX_SIZE*MATRIX_SIZE; j<2*MATRIX_SIZE*MATRIX_SIZE+3; j++) {
  //  if (((j - 3) % MATRIX_SIZE) == 0)
  //    printf("\n");
  //  printf(" %f", h_params[j]);
  //}
  printf("\n");
  free(h_params);
  return 0;
}
