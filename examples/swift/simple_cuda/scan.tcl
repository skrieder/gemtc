#!/usr/bin/env tclsh

# Simple script to report GEMTC functions available from Tcl

package require sleep 0.0

puts "In package"
set commands [ list ]

foreach cmd [ info commands ] {
    if { [ string match *SLEEP_* $cmd ] } {
        lappend commands $cmd
    }
}
set commands [ lsort $commands ]

puts "SLEEP functions:"
foreach cmd $commands {
    puts $cmd
}
puts " "
puts " "
puts "testing structs"
set p [ new_SLEEP_S  ]
puts $p

SLEEP_S_i_set $p 10
puts "result is: [SLEEP_S_i_get $p]"