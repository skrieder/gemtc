# WORKER.TCL (GEMTC)
# Replacement worker for GEMTC

namespace eval turbine {

    # If this GEMTC was initialized, this is 1
    variable gemtc_initialized
    # Dict of context dicts indexed by rule_id
    variable gemtc_context
    # Number of GEMTC tasks currently running
    variable gemtc_running
    # Maximal number concurrent GEMTC tasks to run
    variable gemtc_limit

    # Main worker loop
    proc worker { } {

	# intialize context
        variable gemtc_initialized
        variable gemtc_running

        if { ! [ info exists gemtc_initialized ] } {
            set gemtc_initialized 1
            set gemtc_context [ dict create ]
            set gemtc_running 0
            set gemtc_limit 10000000
        }

	# This is a hack for now. We know that we want to make GEMTC calls.
	# At some point we should introduce logic to call GEMTC only if needed
	GEMTC_Setup 1000000

        global WORK_TYPE

        while { true } {
            # puts "gemtc_running: $gemtc_running"
            if { $gemtc_running < $gemtc_limit } {
                if { $gemtc_running == 0 } {
                    set msg [ adlb::get $WORK_TYPE(WORK) answer_rank ]
                } else {
                    set msg [ adlb::iget $WORK_TYPE(WORK) answer_rank ]
                }

                if { ! [ string length $msg ] } {
                    # puts "empty"
                    GEMTC_Cleanup
		    break
                } elseif { ! [ string equal $msg ADLB_NOTHING ] } {
                    set rule_id [ lreplace $msg 1 end ]
                    set command [ lreplace $msg 0 0 ]
                    do_work $answer_rank $rule_id $command
                }
            }
            gemtc_check
        }
    }

    # Worker: do actual work, handle errors, report back when complete
    proc do_work { answer_rank rule_id command } {

        global WORK_TYPE

        #debug "rule_id: $rule_id"
        #debug "work: $command"
        #debug "eval: $command"

	# Get a substring of the command to
	# help determine if it starts with "gemtc_"
	set checkString [string range $command 0 5]

	# Determine if $command is normal or should call gemtc
        if { [ string compare $checkString "gemtc_" ] == 1 } {

            # Normal Turbine command
            #debug "Normal Turbine Command"
            if { [ catch { eval $command } e ] } {
                puts "Normal Turbine Command Error"
		puts "work unit error: "
                puts $e
                # puts "[dict get $e -errorinfo]"
                error "rule: transform failed in command: $command"
            }
        } else {
	    #debug "Launching gemtc_do_work"
            gemtc_do_work $rule_id $command
        }
    }

    proc gemtc_do_work { rule_id command } {

        variable gemtc_context

        variable gemtc_running

        incr gemtc_running

	# parse out args
        set subcommand_args [ string range $command 6 end ]
        set subcommand [ lreplace $subcommand_args 1 end ]
        set args [ lreplace $subcommand_args 0 0 ]
        set context [ dict create cmd $subcommand args $args result NULL]
        dict set gemtc_context $rule_id $context

        # Call gemtc_begin to get the swift user parameters

	switch $subcommand {
	    sleep {
	    set sup [ gemtc::gemtc_sleep_begin {*}$args ]
	    }
	    mdproxy {
	    set sup [ gemtc::gemtc_mdproxy_begin {*}$args ]
	    }
	}
	# set sup [ eval gemtc::gemtc_${subcommand}_begin no_stack {*}$args ]
	# Call gemtc_put
        if { [ catch { gemtc_put $rule_id $command $sup } e ] } {
            puts "work unit error in gemtc_put: "
            puts $e
            error "rule: transform failed in command: $command"
        }

    }

    proc gemtc_put { rule_id command sleeptime_user_param } {

        variable gemtc_context

        #puts "gemtc_put: sleeptime_user_param $sleeptime_user_param"

	# Parse out the command and get the string name of the TaskID
	set TaskIDString [ gemtc_get_taskid $command ]

	# Enter a switch and get the integer mapped to the TaskID
	set TaskIDInt [ gemtc_get_taskid_int $TaskIDString  ]
	set sizeOfInt [ GEMTC_SizeOfInt ]
	set h_sleeptime_ptr [ GEMTC_CPUMalloc $sizeOfInt ]

	# set the sleeptime to the swift user params
	GEMTC_CPU_SetInt $h_sleeptime_ptr $sleeptime_user_param

	## Allocate an int
	set d_sleeptime [ GEMTC_GPUMalloc $sizeOfInt ]

	## GEMTC_MemcpyHostToDevice *host *device sizeof(int)
	GEMTC_MemcpyHostToDevice $d_sleeptime $h_sleeptime_ptr $sizeOfInt

	## Set taskIDINT to be the unique rule_id from swift
	# set taskIDInt [ IntFromStr $rule_id ]

	## GEMTC_Push Type Threads ID *d_params
	GEMTC_Push 0 32 $rule_id $d_sleeptime
	#GEMTC_Push 0 32 $taskIDInt $d_sleeptime
    }

    proc gemtc_check { } {

        variable gemtc_context
        variable gemtc_running

	# Call gemtc_get
        set rule_id [ gemtc_get ]
        if { $rule_id == -1 } {
            return
        }

        # GPU continuation
        #puts "continuation..."
        set context [ dict get $gemtc_context $rule_id ]
	set cmd    [ dict get $context cmd ]
	set args   [ dict get $context args ]
	set value  [ dict get $context result ]
        #puts "context: $context"
        #puts "args: $args"
        #puts "value: $value"

	# should this change?
	switch $cmd {
	    sleep {
		gemtc::gemtc_sleep_end {*}$args $value
	    }
	    mdproxy {
		gemtc::gemtc_mdproxy_end {*}$args $value
	    }
	}

	#eval gemtc::gemtc_${cmd}_end no_stack {*}$args $value
        dict unset gemtc_context $rule_id

        incr gemtc_running -1
    }

    proc gemtc_get { } {
        variable gemtc_context

	# debug "In gemtc_get"

	# debug "gemtc_context is: $gemtc_context"
	set sizeOfInt [ GEMTC_SizeOfInt ]

	# Allocate some pointers
	set h_ID_ptr [ GEMTC_CPUMallocInt $sizeOfInt ]
	set d_params_ptr [ GEMTC_CPUMallocVP $sizeOfInt ]
	set d_params_ptr_ptr [ GEMTC_CPUMallocVPP $sizeOfInt ]
	set h_params_ptr [ GEMTC_CPUMallocVP $sizeOfInt ]

	# Call Poll
        GEMTC_Poll $h_ID_ptr $d_params_ptr_ptr
        set h_ID_value [ GEMTC_CPU_GetInt $h_ID_ptr ]
	if { $h_ID_value == -1 } {
            # nothing completed
            # delay for debugging
	    return -1
        }

        #puts "something completed!"

        # something completed - retrieve result
        set rule_id $h_ID_value
	set d_params_ptr [VPFromVPP $d_params_ptr_ptr]
	## GEMTC_MemcpyHostToDevice *host *device sizeof(int)
	GEMTC_MemcpyDeviceToHost $h_params_ptr $d_params_ptr $sizeOfInt
	set resultInt [ IntFromVP $h_params_ptr ]

        #puts "resultInt: $resultInt"

        # store result in context
        dict set gemtc_context $rule_id result $resultInt

	# debug "FIX: not freeing any memory, fix later"
	## Free Memory
#	GEMTC_GPUFree $d_sleeptime
#	GEMTC_CPUFreeVP $h_sleeptime_ptr
#	GEMTC_CPUFreeVP $h_ID_ptr
#	GEMTC_CPUFree $h_params_ptr
#	GEMTC_CPUFreeVP $h_sleeptime_ptr
#	GEMTC_CPUFree $d_params_ptr
	# GEMTC_CPUFreeVP $d_params_ptr_ptr

        return $rule_id
    }

    # This function takes a string command to parse
    # then gets the string representation of the TaskID
    proc gemtc_get_taskid { stringToParse } {
	# Parse gemtc_ command to get details
	set cmdLen [ string length $stringToParse ]
	# debug "String length is: $cmdLen "

	# Check Switch to see which code to execute
	# Using 6 here due to the 6 chars in "gemtc_"
	set rest [ string range $stringToParse 6 $cmdLen ]
	# debug "The rest of the string is: $rest"
	set dashIndex [ string first "-" $rest ]
	# debug "Dash index in rest is: $dashIndex"

	set TaskID [ string range $rest 0 [ expr $dashIndex - 1 ] ]

	return $TaskID
    }

    proc gemtc_get_taskid_int { stringToCheck } {
	## CODE TO-DO - add more ifs or change to swift
	# Switch statment assigning ints from string value checks
	switch $stringToCheck{
	    sleep {
		return 0
	    }
	    mdproxy {
		return 20
	    }
	}
    }
}

