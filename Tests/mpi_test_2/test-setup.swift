#include <builtins.swift>
#include "setup.swift"
#include <io.swift>
#include <sys.swift>

main {
     float x = c_setup(0);
     wait (x) {
     	  printf("Setup called finished.\n");
     }

     float A[];

     foreach i in [0:1:1]{
     	     A[i] = c_run(0);
	     wait(A[i]){
		printf("a single run finished");
	     }
     }
     float w;
     for(int j = 0; j < 2; j = j+1){
          wait(A[j]){
		if(j==1){
		     w=0.0;
		}
	  }
     }
     wait(w){
	float z = c_cleanup(0);
     	wait (z) {
             printf("Cleanup finished.\n");
     	}
     }
}
