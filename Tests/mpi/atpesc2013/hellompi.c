#include <mpi.h>
#include <stdio.h>


int main(int argc, char *argv[])
  {
    int ret;
    int myrank, nprocs;

    ret=MPI_Init(&argc,&argv);
 
    if (ret!=MPI_SUCCESS)
      {
	fprintf(stderr,"MPI_Init() failed\n");
	abort();
      }


    ret=MPI_Comm_rank(MPI_COMM_WORLD,&myrank);
 
    if (ret!=MPI_SUCCESS)
      {
	fprintf(stderr,"msg_init: MPI_Comm_rank() failed\n");
	abort();
      }

    ret=MPI_Comm_size(MPI_COMM_WORLD,&nprocs);
 
    if (ret!=MPI_SUCCESS)
      {
	fprintf(stderr,"msg_init: MPI_Comm_size() failed\n");
	abort();
      }

    
    /* Only print a message from some ranks */
    if ( (myrank < 8) || (myrank==nprocs-1) )
      printf("%d: Hello!\n",myrank);


    MPI_Finalize();

    return(0);
  }


