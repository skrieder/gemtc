/*
	Test program for evaluating the gemtc worker and the MDProxy Application. -Scott
*/

import io;
import gemtc;

main
{
  // set some parameters
  int np = 10;
  int nd = 2;
  float mass = 1.1;

  float initial_position_array[] = fill_array_with_randoms(np * nd); // fill an initial position array with random floats
  print_array(initial_position_array); // print the first array to see changes after gemtc call
  float result_position_array[] = fill_array_with_zeros(np * nd); // not needed, sanity step
  result_position_array = gemtc_mdproxy(np, nd, mass, initial_position_array); // call gemtc return new positions
  print_array(result_position_array); // this should print a result pos array manipualted by the GPU
}
