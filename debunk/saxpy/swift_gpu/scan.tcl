#!/usr/bin/env tclsh

# Simple script to report GEMTC functions available from Tcl

package require saxpy 0.0

set commands [ list ]

foreach cmd [ info commands ] {
    if { [ string match *SAXPY_* $cmd ] } {
        lappend commands $cmd
    }
}
set commands [ lsort $commands ]

puts "GEMTC functions:"
foreach cmd $commands {
    puts $cmd
}
puts " "
puts " "
puts "testing structs"
set p [ new_SAXPY_S  ]
puts $p

SAXPY_S_i_set $p 10
puts "result is: [GEMTC_S_i_get $p]"