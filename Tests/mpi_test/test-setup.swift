#include <builtins.swift>
#include "setup.swift"
#include <io.swift>
#include <sys.swift>

main {
     float A[];

     foreach i in [0:0:1]{
     	     A[i] = c_setup(0);
	     wait(A[i]){
		printf("a single run finished");
	     }
     }
}
