#!/usr/bin/env tclsh

# Simple script to report GEMTC functions available from Tcl

package require gemtc 0.0

set commands [ list ]

foreach cmd [ info commands ] {
    if { [ string match *GEMTC_* $cmd ] } {
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
set p [ new_GEMTC_S  ]
puts $p

GEMTC_S_i_set $p 10
puts "result is: [GEMTC_S_i_get $p]"