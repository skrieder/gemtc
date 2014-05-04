package provide sleep 0.0

proc sleep_tcl { n } { 
    puts "Testing sleep from tcl"
    sleep_wrapper $n
    puts "sleep test complete from tcl"
    return 1
}
