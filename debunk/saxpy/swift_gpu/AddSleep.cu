#include <stdio.h>

// This is a kernel that does no real work but runs at least for a specified number of clocks           
__global__ void clock_block(clock_t *d_o, clock_t clock_count)
{
  unsigned int start_clock = (unsigned int) clock();
  clock_t clock_offset = 0;
  while (clock_offset < clock_count)
    {
      unsigned int end_clock = (unsigned int) clock();
      // The code below should work like                                                               
      // this (thanks to modular arithmetics):                                                         
      //                                                                                               
      // clock_offset = (clock_t) (end_clock > start_clock ?                                           
      //                           end_clock - start_clock :                                           
      //                           end_clock + (0xffffffffu - start_clock));                           
      //                                                                                               
      // Indeed, let m = 2^32 then                                                                     
      // end - start = end + m - start (mod m).                                                        

      clock_offset = (clock_t)(end_clock - start_clock);
    }
  d_o[0] = clock_offset;
  printf("End Clock Block\n");
}

