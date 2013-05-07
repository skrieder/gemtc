#include "../../gemtc.cu"
#include<stdio.h>
#include<stdlib.h>

#define MIN(a,b) (a<b?a:b)

int main(int argc, char **argv){

  char s1[32], s2[32];
  printf("Enter the first string:\n");
  scanf("%s", s1);

  printf("Enter the second string:\n");
  scanf("%s", s2);

  int ls1 = (int)strlen(s1);
  int ls2 = (int)strlen(s2);

  int mem_needed = 2*sizeof(int) + ls1 + ls2 + 2 + MIN(ls1,ls2); 
  
  gemtcSetup(25600, 0);
  void* d_memory = gemtcGPUMalloc(mem_needed);

  gemtcMemcpyHostToDevice(d_memory, &ls1, sizeof(int));
  gemtcMemcpyHostToDevice(((int*)d_memory)+1, &ls2, sizeof(int));
  gemtcMemcpyHostToDevice(((int*)d_memory)+2, s1, ls1+1);
  gemtcMemcpyHostToDevice(((char*)d_memory)+8+ls1+1, s2, ls2+1);

  gemtcPush(15, 32, 100, d_memory); 

  void *ret=NULL;
  int id;

  while(ret==NULL){
    gemtcPoll(&id, &ret);
  }

  void *h_ret = malloc(mem_needed);
  gemtcMemcpyDeviceToHost(h_ret, ret, mem_needed);

  char *common = ((char*)h_ret) + 8 + ls1 + ls2 + 2; 
  printf("result = %s\n", common);

  free(h_ret);
  gemtcCleanup();

  return 0;
}
