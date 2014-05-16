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

  float a_position_array[];
  float b_position_array[];
  float c_position_array[];
  float d_position_array[];

  a_position_array = mdproxy_create_random_vector(n); // sudo-random
  b_position_array = a_position_array;
  c_position_array = a_position_array;
  d_position_array = a_position_array;

  // convert to blob
  blob a_blob = blob_from_floats(a_position_array);
  blob b_blob = blob_from_floats(b_position_array);
  blob c_blob = blob_from_floats(c_position_array);
  blob d_blob = blob_from_floats(d_position_array);

  // obtain a new result array
  blob a_result = gemtc_mdproxy(np, a_blob); // maybe this should be n
  blob b_result = gemtc_mdproxy(np, b_blob); // maybe this should be n
  blob c_result = gemtc_mdproxy(np, c_blob); // maybe this should be n
  blob d_result = gemtc_mdproxy(np, d_blob); // maybe this should be n

  a_result_array = floats_from_blob(a_result);
  b_result_array = floats_from_blob(b_result);
  c_result_array = floats_from_blob(c_result);
  d_result_array = floats_from_blob(d_result);
}
