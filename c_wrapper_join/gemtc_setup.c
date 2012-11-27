extern void setupGemtc(int);

#include<stdio.h>

int main(){
  printf("Running GeMTC setup.\n");
  setupGemtc(2560);
  printf("Setup complete.\n");
  return 0;
}
