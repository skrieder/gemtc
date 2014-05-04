/*
	Test program for evaluating the gemtc worker and the MDProxy Application. -Scott
*/
import io;
import gemtc;
import sys;

main
{
  // setup
  int np = toint(argv("np"));    // number of particles
  int nd = 2;       // number of dimensions
  int n = np * nd;  // total size
  float mass = 1.1; // mass

  // declare arrays
  float position_array[]; // initial array
  float result_array[];   // result

  // fill the position array with *random* floats
  position_array = mdproxy_create_random_vector(n); // sudo-random

  printf("Initial Vector\n");
  // Un-comment to print initial vector
    foreach value, index in position_array
  {
     printf("position_array[%i] = %f", index, value);
  }
  

  // convert to blob
  blob b = blob_from_floats(position_array);

  //Write b to a file

  /*  // uncomment to print out array  
  foreach value, index in position_array
  {
    printf("position_array[%i] = %f\n", index, value);
    }*/

  // obtain a new result array
  blob result = gemtc_mdproxy(np, b); // maybe this should be n

  result_array = floats_from_blob(result);
  // uncomment to print out array

  printf("Result Vector\n");  
  foreach value, index in result_array
  {
    printf("result_array[%i] = %f", index, value);
  }

  // write result to a file

}
