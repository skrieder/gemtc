#include <stdio.h>
 
void foo(){
  printf("FOOO\n");
} 

void bar(void)
{
  puts("Hello, I'm a shared library, and I'm printing from bar.");
  foo();
}


