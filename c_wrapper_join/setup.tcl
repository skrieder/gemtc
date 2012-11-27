
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

    proc c_run { stack output inputs } {

#tickle, output log, list of variables that swift could wait on, tickle code to run
        turbine::rule "c_run-$output" $inputs $turbine::WORK \
            "setup::c_run_body $output $inputs"
     }

    proc c_run_body {o x} {

        set x [ turbine::retrieve_float $x ]
        
        set result [ setup::c::c_run $x ]
        
	#puts "result: $result"
        turbine::store_float $o $result
    }

    proc c_cleanup { stack output inputs } {

#tickle, output log, list of variables that swift could wait on, tickle code to run
        turbine::rule "c_cleanup-$output" $inputs $turbine::WORK \
            "setup::c_cleanup_body $output $inputs"
     }

    proc c_cleanup_body {o x} {

        set x [ turbine::retrieve_float $x ]
        
        set result [ setup::c::c_cleanup $x ]
        
	#puts "result: $result"
        turbine::store_float $o $result
    }

}
