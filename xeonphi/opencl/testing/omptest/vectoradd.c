#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
//need to modify

void add(int *a, int *b, int *c, size_t n,int num){
    int i;
    
    omp_set_num_threads(num);
    
    #pragma omp parallel for
    for(i = 0; i < n; ++i) {
        c[i] = a[i] + b[i];
    }
}

void main(int argc, char *argv[]) {
    int *a, *b, *c;
    int i;
    //struct timespec start, finish;
    //double elapsed;
	int n;
	n=atoi(argv[2]);
    a = (int *) malloc(n*sizeof(int));
    b = (int *) malloc(n*sizeof(int));
    c = (int *) malloc(n*sizeof(int));


    for(i = 0; i < n; ++i){
        a[i] = i;
        b[i] = i;
    }	
	int num_threads;
num_threads=atoi(argv[1]);
   // clock_gettime(CLOCK_MONOTONIC, &start);
    add(a,b,c,n,num_threads);
    //clock_gettime(CLOCK_MONOTONIC, &finish);
    //elapsed = (finish.tv_sec - start.tv_sec);
   // elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;

    //printf("\n time = %le  ",elapsed);

    free(a);
    free(b);
    free(c);
    return;
}
