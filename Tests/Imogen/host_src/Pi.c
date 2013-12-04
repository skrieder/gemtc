/* Program to compute Pi using Monte Carlo methods */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <unistd.h> 
#include <limits.h>
#include <time.h>
#define SEED 35791246

int main(int argc, char **argv){
   int NUM_TASKS;
   int niter=0;

   struct timespec start, end;
   double time_spent = 0.0;

   if(argc>2){
      NUM_TASKS = atoi(argv[1]);
      niter = atoi(argv[2]);
   } else {
      printf("This test requires two parameter:\n");
      printf("int NUM_TASKS\n");
      printf("int iterations\n");
      printf("where  NUM_TASKS is the total numer of task\n");
      printf("Enter the number of iterations used to estimate pi: ");
      printf("where  iterations is the total numer of task\n");
      exit(1);
   }

   double x,y;
   int i, j ,count=0; /* # of points in the 1st quadrant of unit circle */
   double z;
   double pi;

   clock_gettime(CLOCK_MONOTONIC_RAW, &start);

   /* initialize random numbers */
   srand(SEED);
   double *random = (double*)malloc(sizeof(double)*niter*2);
   for ( i=0; i<niter*2; i++) {
      random[i] = (double)rand()/RAND_MAX;
   }
   for(j = 0; j < NUM_TASKS; j++) {
      count=0;
      for ( i=0; i<niter; i++) {
         x = random[i];
         y = random[i+niter];
         z = x*x+y*y;
         if (z<=1) count++;
      }
      pi=(double)count/niter*4;
   }
   printf("# of trials= %d , estimate of pi is %g \n",niter,pi);
   clock_gettime(CLOCK_MONOTONIC_RAW, &end);
   /* Evaulate time taken for the computation */
   time_spent = (end.tv_sec - start.tv_sec) +  (end.tv_nsec - start.tv_nsec)/1e9;

   printf(" Time taken %f seconds\n", time_spent);
   printf("\n");
   free(random);
   return 0;
}
