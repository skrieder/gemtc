#include "saxpy.cu"

int main(int argc, char * argv[]){

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
  else if(argc == 3){
    printf("in arg\n");
    num_elements = atoi(argv[1]);
    num_threads = atoi(argv[2]);

    //    printf("%d\n %d\n", num_elements, num_threads);
  }

  cuda_saxpy_launcher(num_elements, num_threads);

  return 0;
}
