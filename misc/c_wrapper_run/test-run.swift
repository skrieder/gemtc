
#include <builtins.swift>
#include "run.swift"
#include <io.swift>
#include <sys.swift>

main {

 // run the sleep
     foreach i in [1:1:1]{
               float y = c_run(0);
	       wait (y) {
    	       	    printf("Working");
		    }
	}
}
