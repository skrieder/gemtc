package provide hist 0.0
namespace eval hist {
      proc hist_tcl { v } {
        # Unpack the list
        set ptr [ lindex $v 0 ]
        set len [ lindex $v 1 ]
        # Get the number of numbers to sum
        set count [ expr $len / [ blobutils_sizeof_float ] ]

        # Convert the pointer number to a SWIG pointer
        set ptr [ blobutils_cast_int_to_dbl_ptr $ptr ]

        # Call the C function
        set s [ hist $ptr $count ]
	set r [ blobutils_cast_to_int $s ]
        return [ list $r 8 ]
        # Pack result as a Turbine blob and return it
    }
}
