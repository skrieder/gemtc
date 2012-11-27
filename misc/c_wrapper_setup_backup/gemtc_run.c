extern void *run(int, int, void*, int);

#include<stdio.h>

int main(int argc, char **argv){
  int i;
  for(i=0; i<5; i++){
    int sleepTime = 1000;
    void *ret = run(0, 32, &sleepTime, sizeof(int));
    printf("Finished job with parameter: %d\n", *(int *)ret);
  }
  return 0;
}
