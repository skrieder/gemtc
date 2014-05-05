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
  int loopCount = toint(argv("bound"));
  int nd = 3;       // number of dimensions
  int n = np * nd;  // total size
  float mass = 1.1; // mass
  float A[][];
  blob B[];
  blob R[];
  float F[][];
  float T[];

<<<<<<< .mine
  //  foreach i in [1:n:1]{
  T = constructArray(n);
    //}
 
  foreach i in [0:n-1:1]{
    printf("T[%d] = %f", i, T[i]);
  }
=======
  //float test_float = 1337;
>>>>>>> .r10844

<<<<<<< .mine
  printf("Setting A to T");
  A[0] = T;
  printf("Complete");

  printf("Setting B to blob of A");
=======
  // Create a random array
  //  A[0] = mdproxy_create_random_vector(n);

  // testing issue with random vector
  //foreach i in [1:loopCount:1]{
  //  A[i] = [1.1,2.2,3.3];
  //}

  T = constructArray(n);
  A[0] = T;

>>>>>>> .r10844
  B[0] = blob_from_floats(A[0]);
  printf("Complete");

  printf("Duplicate B");
  // convert float arrays to blobs
  foreach i in [1:loopCount:1]{
    B[i] = B[0];
  }
  printf("Complete");

  printf("run gemtc");
  // obtain a new blob result array
  foreach i in [1:loopCount:1]{
    R[i] = gemtc_mdproxy(np, B[i]);
  }
  printf("Complete");
}

(float A[]) constructArray(int n) {
  foreach i in [0:n:1]{
    A[i] = 1.9;
  }
}
