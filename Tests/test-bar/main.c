#include <stdio.h>
//#include "main.h"

extern void bar(void);
 
int main(void)
{
  puts("This is a shared library test...");
  bar();
  return 0;
}
