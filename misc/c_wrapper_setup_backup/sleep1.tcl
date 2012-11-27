
# sleep1 Tcl wrapper

namespace eval sleep1 {

    proc c_sleep { stack output inputs } {

#tickle, output log, list of variables that swift could wait on, tickle code to run
        turbine::rule "c_sleep-$output" $inputs $turbine::WORK \
            "sleep1::c_sleep_body $output $inputs"
     }

    proc c_sleep_body {o x} {

        set x [ turbine::retrieve_float $x ]
        
        set result [ sleep1::c::c_sleep $x ]
        
	#puts "result: $result"
        turbine::store_float $o $result
    }

}
