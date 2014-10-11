#include<stdlib.h>
#include<stdio.h>
#include<omp.h>
#include<time.h>


void main(int argc, char *argv[])
{
    int **a, **b, **result;
    int i, j, k,r1, c1, r2, c2;
    int nthreads;
    r1 = atoi(argv[2]); //500
    c1 = r1; //500
    r2 = r1; //500
    c2 = r1; //500
    /* Initializing the clock */
  
   a = (int **)malloc(r1 * sizeof(int*));
   for(i = 0; i < r1; i++) 
      a[i] = (int *)malloc(c1 * sizeof(int));
   b = (int **)malloc(r1 * sizeof(int*));
   for(i = 0; i < r2; i++) 
      b[i] = (int *)malloc(c2 * sizeof(int));
   result = (int **)malloc(r1 * sizeof(int*));
   for(i = 0; i < r1; i++) 
      result[i] = (int *)malloc(c2 * sizeof(int));

/* Initializing elements of matrix mult to 0.*/
   for(i=0; i<r1; i++)
      for(j=0; j<c2; j++)
	 {
	    result[i][j]=0;
	 }
int num=atoi(argv[1]);
   omp_set_num_threads(num);

   int sum=0;
   //clock_gettime(CLOCK_MONOTONIC, &start);
/* Multiplying matrix a and b and storing in array mult. */
   
      #pragma omp parallel for collapse(3) 
      
	 for(i=0; i<r1; i++)//schedule(dynamic, r1)
	 for(j=0; j<c2; j++)
	 for(k=0; k<c1; k++)
	 {
	    result[i][j]+= a[i][k]*b[k][j];
	 }
   //clock_gettime(CLOCK_MONOTONIC, &finish); 
   free(a);
   free(b);
/* Displaying the multiplication of two matrix. */
   /* printf("\nOutput Matrix:\n");
    #pragma omp parallel 
    {
       //#pragma omp single
       //{
	 nthreads = omp_get_num_threads();
	 printf("thr = %d \n", nthreads);
//       }
       #pragma omp for   
	 for(i=0; i<r1; i++)
	 for(j=0; j<c2; j++)
	 {
	  //  #pragma omp critical
	    //{
	   printf("%d  ",mult[i][j]);
	    if(j==c2-1)
		  printf("\n\n");
	    //}
	 }
    }
*/  /* Stopping the clock */
  // elapsed = (finish.tv_sec - start.tv_sec);
  // elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;

    //printf("\n time = %le  ",elapsed);
    return;
}
