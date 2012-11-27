
#include <builtins.swift>
#include "setup.swift"
#include <io.swift>
#include <sys.swift>

main {

 // run the sleep
     foreach i in [1:1:1]{
               float y = c_setup(0);
	       wait (y) {
    	       	    printf("Working");
		    }
	}
}
