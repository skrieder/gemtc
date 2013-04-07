#include <stdio.h>
#include <string.h>

#define MIN(a,b) (a<b?a:b)
__device__ size_t string_len(const char *str){
  const char *s;
  for(s=str; *s; ++s);
  return(s-str);
}

__device__ void LCSubstring(void *params){
  //char* output = (char*)params;
  //char *string = "New message!!";
  //int i=0;
  //while(i<14){
  //  output[i]=string[i];
  //  i++;
  //}
  char** strs = (char**)(params); 
  
  char* s1 = *strs;
  char* s2 = *++strs; 
  int s1_size = string_len(s1); 
  int s2_size = string_len(s2);

  if(s1_size == 0 || s2_size == 0){
    return;
  } 

  int* table = (int*)malloc(sizeof(int)*s1_size*s2_size)
  int i,j;

  //Make sure all the values in the table are set to 0. 
  for(i=0; i<s1_size; i++){
    for(j=0; j<s2_size; j++){
      table[i][j] = 0;
    }
  }

  int max = 0; 
  char* ret = (char*)malloc(MIN(s1_size, s2_size)); 

  for(i=0; i<s1_size;i++){
    for(j=0; j<s2_size;j++){
      if(s1[i] == s2[j]){
        if(i==0 || j==0){
          table[i][j] = 1;
        }
        else{
          table[i][j] = table[i-1][j-1] + 1;
        }
        if(table[i][j] > max){
          max = table[i][j];
          strncpy(ret, &s1[i-max+1], max);
        }
      }
    }
  }

}
