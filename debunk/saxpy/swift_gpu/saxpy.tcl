package provide saxpy 0.0

proc saxpy_tcl { n } { 
    puts "Testing saxpy from tcl"
    cuda_saxpy_launcher $n $n
    puts "saxpy test complete from tcl"
    return 1
}
