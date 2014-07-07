#include<stdlib.h>
#include<stdio.h>
#include<omp.h>
#include<time.h>


int main()
{
  //  int mult[5010][5010];
    int **a, **b, **result;
    int i, j, k,r1, c1, r2, c2;
    int nthreads;
    clock_t begin, end;
    double time;
    
    struct timespec start, finish;
   double elapsed;
  /*  printf("Enter rows and column for first matrix: ");
    scanf("%d%d", &r1, &c1);
    printf("Enter rows and column for second matrix: ");
    scanf("%d%d",&r2, &c2);

/* If colum of first matrix in not equal to row of second matrix, asking user to enter the size of matrix again. 
    while (c1!=r2)
    {
        printf("Error! column of first matrix not equal to row of second.\n");
        printf("Enter rows and column for first matrix: ");
        scanf("%d%d", &r1, &c1);
        printf("Enter rows and column for second matrix: ");
        scanf("%d%d",&r2, &c2);
    }*/
    r1 = 500;
    c1 = 500;
    r2 = 500;
    c2 = 500;
    /* Initializing the clock */
  
   
   
/* Storing elements of first matrix. */
   /* printf("\nEnter elements of matrix 1:\n");
    #pragma omp parallel 
    {
      #pragma omp master
      {
	 nthreads = omp_get_num_threads();
	 printf("\nnthr = %d \n ", nthreads);
      }
      #pragma omp for collapse(2) schedule(dynamic, r1)
	 for(i=0; i<r1; i++)
	 for(j=0; j<c1; j++)
	 {
	 //printf("Enter elements a%d%d: ",i+1,j+1);
	 scanf("%d",&a[i][j]);
	 }
    }

/* Storing elements of second matrix. */
  /*  printf("\nEnter elements of matrix 2:\n");
    #pragma omp parallel 
    {
       #pragma omp master
       {
	 nthreads = omp_get_num_threads();
	 printf("\nnthr = %d \n ", nthreads);
       }
       #pragma omp for collapse(2) schedule(dynamic, r1)
	 for(i=0; i<r2; i++)
	 for(j=0; j<c2; j++)
	 {
	    //printf("Enter elements b%d%d: ",i+1,j+1);
	    scanf("%d",&b[i][j]);
	 }
    }*/
  
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

   omp_set_num_threads(1);

   int sum=0;
   clock_gettime(CLOCK_MONOTONIC, &start);
/* Multiplying matrix a and b and storing in array mult. */
   
      #pragma omp parallel for collapse(3) 
      
	 for(i=0; i<r1; i++)//schedule(dynamic, r1)
	 for(j=0; j<c2; j++)
	 for(k=0; k<c1; k++)
	 {
	    result[i][j]+= a[i][k]*b[k][j];
	 }
    
   clock_gettime(CLOCK_MONOTONIC, &finish); 
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
    /* Stopping the clock */
   elapsed = (finish.tv_sec - start.tv_sec);
   elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;

    printf("\n time = %le  ",elapsed);
    return 0;
}