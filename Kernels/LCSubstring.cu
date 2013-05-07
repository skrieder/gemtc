#include<stdio.h>

#define MIN(a,b) (a<b?a:b)
#define MAX(a,b) (a>b?a:b)

__device__ size_t string_len(const char *str){
  const char *s;
  for(s=str; *s; ++s);
  return (s-str);
}

__device__ char* string_copy(char *dest, const char *src, size_t n){
  size_t k;
  for(k=0; k < n && src[k] != '\0'; k++){
    dest[k] = src[k];
  }
  for(; k < n; k++){
    dest[k] = '\0';
  }

  return dest; 
}

__device__ void LCSubstring(void *params){
  int *s1_size = (int*)params;
  int *s2_size = s1_size + 1;

  char *s1 = (char*)(s2_size+1);
  char *s2 = s1 + *s1_size + 1;

  char *ret = s2 + *s2_size + 1;
  *ret = NULL;

  if(*s1_size > 32 || *s2_size > 32 || *s1_size <= 0 || *s2_size <= 0){
      return;
  } 

  int max = MAX(*s1_size, *s2_size);
  int min = MIN(*s1_size, *s2_size);

  int i = threadIdx.x % max;

  int table[32][32], j;

  for(j=0; j<min; j++){
    table[i][j] = 0;
  }

  int longest = 0; 

  //TODO: This section can be parallelized. 
  for(i=0; i<max;i++){
    for(j=0; j<min;j++){
      if(s1[i] == s2[j]){
        if(i==0 || j==0){
          table[i][j] = 1;
        }
        else{
          table[i][j] = table[i-1][j-1] + 1;
        }
        if(table[i][j] > longest){
          longest = table[i][j];
          string_copy(ret, &s1[i-longest+1], longest);
        }
      }
    }
  }

}
