#include <stdio.h>

//__global__ void kernel( void ) {
  // does nothing
//}

int main(int argc, char** argv) {
  
  // default the loop count to equal 1
  int loopCount = 1;

  // take in a command line arg to set the loop count
  if(argc > 1){
    loopCount = atoi(argv[1]);
  }

  // delcare two variables
  int *dev_a;

  // get the size of an int for the cuda malloc
  int size = 1;

  // malloc on the device

  // loop over the loop count and copy to device
  for(int i = 0; i < loopCount; i++){
    cudaMalloc((void **)&dev_a, size);
    //cudaFree(dev_a);
  }

  return 0;
}
