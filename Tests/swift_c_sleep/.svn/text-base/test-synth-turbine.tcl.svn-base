
package require turbine 0.0.1
package require synth1 0.0.1

proc rules { } {

    turbine::allocate s1 string
    turbine::allocate s2 string
    turbine::allocate o  string
    turbine::set_string $s1 "hello"
    turbine::set_string $s2 "bye"
    synth1::c_strcat no_stack [ list $o ] [ list $s1 $s2 ]
    turbine::trace no_stack [] [ list $o ]
}

turbine::defaults
turbine::init $engines $servers
turbine::start rules
turbine::finalize

puts OK
