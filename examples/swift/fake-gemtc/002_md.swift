/*
	Test program for evaluating the gemtc worker and the MDProxy Application. -Scott
*/
import sys;
import io;
import gemtc;

main
{
  // setup
  int np = toint(argv("array_size"));    // number of particles
  int nd = 2;       // number of dimensions
  int n = np * nd;  // total size
  float mass = 1.1; // mass

  float a_position_array = mdproxy_create_random_vector(n); // sudo-random
  float b_position_array = a_position_array;

  // Un-comment to print initial vector
/*  foreach value, index in position_array
  {
     printf("position_array[%i] = %f", index, value);
  }
*/
  // convert to blob
  blob b = blob_from_floats(a_position_array);
  blob c = blob_from_floats(b_position_array);

  /*  // uncomment to print out array  
  foreach value, index in position_array
  {
    printf("position_array[%i] = %f\n", index, value);
    }*/

  // obtain a new result array
  blob a_result = gemtc_mdproxy(np, b); // maybe this should be n
  blob b_result = gemtc_mdproxy(np, c); // maybe this should be n

  a_result_array = floats_from_blob(a_result);
  b_result_array = floats_from_blob(b_result);
/*
  // uncomment to print out array
  foreach value, index in result_array
  {
    printf("result_array[%i] = %f", index, value);
  }
  */
}
