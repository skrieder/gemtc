#include "saxpy.cu"

int main(int argc, int argv[]){

  printf("In test saxpy.\n");

  int num_threads;
  int num_elements;

  if ( argc != 3 ) /* argc should be 3 for correct execution */
    {
      /* We print argv[0] assuming it is the program name */
      printf("usage: %s (int) <elements_in_vector> (int) <num_threads>\n", argv[0] );
      printf("Running with default values. 1000 and 1\n");
      num_threads = 1;
      num_elements = 1000;
    }


  return 0;
}
