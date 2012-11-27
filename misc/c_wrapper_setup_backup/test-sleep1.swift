
#include <builtins.swift>
#include "sleep1.swift"
#include <io.swift>
#include <sys.swift>

main {

     int bound = 2500;
//     int bound = toint(argv("bound"));
//     float sleepTime = tofloat(argv("sleeptime"));

 // run the sleep
     float A[];
     foreach i in [1:bound:1]{
               A[i] = c_sleep(0);
	       wait (A[i]) {
//    	       	    printf("Run %i completed.", i);
		    }
	}
}
