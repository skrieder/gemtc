#include <stdio.h>
#include <stdlib.h>

int main(){

  int* i;

  int j;

  for(j = 0; j < 1000000; j++){
    i = (int *) malloc(sizeof(int));
  }
  //  printf("Program completed successfuly.\n");

  return 0;
}
