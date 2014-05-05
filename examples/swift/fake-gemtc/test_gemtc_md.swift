/*
	Test program for evaluating the gemtc worker and the MDProxy Application. -Scott
*/

import io;
import sys;
import gemtc;

main
{
  // set some parameters
  int np = toint(argv("array_size"));
  int nd = 3;
  float mass = 1.1;
  int n = np * nd;

  // declare arrays
  float position_array[];
  float result_array[];  

  // fill the position array with *random* floats
  position_array = mdproxy_create_random_vector(n); // currently NOT random
  //foreach value, index in position_array
  //{
    // printf("position_array[%i] = %f", index, value);
  //}


  // convert to blob
  blob b = blob_from_floats(position_array);

  // write the blob to disk


  // uncomment to print out array

  /*
  foreach value, index in position_array
  {
    printf("position_array[%i] = %f", index, value);
  }
  */

  // obtain a new result array
  blob result = gemtc_mdproxy(np, b);

  result_array = floats_from_blob(result);
  /*
  wait(result_array){
    foreach value, index in result_array
    {
      printf("result_array[%i] = %f", index, value);
    }
  }
*/
}
