
# sleep1 Tcl wrapper

namespace eval run {

    proc c_run { stack output inputs } {

#tickle, output log, list of variables that swift could wait on, tickle code to run
        turbine::rule "c_run-$output" $inputs $turbine::WORK \
            "run::c_run_body $output $inputs"
     }

    proc c_run_body {o x} {

        set x [ turbine::retrieve_float $x ]
        
        set result [ run::c::c_run $x ]
        
	#puts "result: $result"
        turbine::store_float $o $result
    }

}
