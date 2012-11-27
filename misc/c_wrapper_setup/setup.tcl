
# sleep1 Tcl wrapper

namespace eval setup {

    proc c_setup { stack output inputs } {

#tickle, output log, list of variables that swift could wait on, tickle code to run
        turbine::rule "c_setup-$output" $inputs $turbine::WORK \
            "setup::c_setup_body $output $inputs"
     }

    proc c_setup_body {o x} {

        set x [ turbine::retrieve_float $x ]
        
        set result [ setup::c::c_setup $x ]
        
	#puts "result: $result"
        turbine::store_float $o $result
    }

}
