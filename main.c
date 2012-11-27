extern void setupGemtc(int);
extern void *run(int, int, void*, int);
extern void cleanupGemtc(void);

#include<stdio.h>

int main(int argc, char **argv){
  setupGemtc(2560);

  int i;
  for(i=0; i<1; i++){
    int sleepTime = 60000000;
    void *ret = run(0, 32, &sleepTime, sizeof(int));
    printf("!!Finished job with parameter: %d\n", *(int *)ret);
  }
  cleanupGemtc();

  return 0;
}
