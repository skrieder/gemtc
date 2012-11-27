#include <builtins.swift>
#include "setup.swift"
#include <io.swift>
#include <sys.swift>

main {
     // define a loop bound
     int bound = 10;

     // call setup
     float x = c_setup(0);
     wait (x) {
     	  printf("Setup called finished.\n");
     }

     float A[];

     // call run, bound many times
     foreach i in [0:bound:1]{
  //   	     printf("Starting run number %i.\n", i);
	     A[i] = c_run(0);
	     wait(A[i]){
    //	          printf("Run number %i finished", i);
    	          }
     }

     // wait on each item in A array
     float w;
     for(int j = 0; j < (bound+1); j = j+1){
     	     wait(A[j]){
	          if(j==bound){
		       w=0.0;
	          }
	     }
     }

     // call cleanup
     wait(w){
	printf("Starting call to cleanup.\n");
	float z = c_cleanup(0);
     	wait (z) {
             printf("Cleanup finished.\n");
     	}
     }
}
