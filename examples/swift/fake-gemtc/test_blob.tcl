package require turbine

# Set the size of Float
set sizeOfFloat [ blobutils_sizeof_float ]
puts "sizeOfFloat: $sizeOfFloat"

# Set the Number of Elements
set num_elements 3

# Set the total amount of memory needed to be (size of float * num_elements )
set mem_needed [ expr "$sizeOfFloat * $num_elements"]

# Allocate a void ptr with size of mem_needed
set test_ptr [ blobutils_malloc $mem_needed ]
puts "test_ptr: $test_ptr"

# Create a new turbine blob
set my_turbine_blob [ new_turbine_blob ]
puts "my_turbine_blob: $my_turbine_blob"
puts "Note: the initial void * is set to NULL and length is set to 0"
puts "turbine_blob_ptr: [ turbine_blob_pointer_get $my_turbine_blob ]"
puts "turbine_blob_length: [ turbine_blob_length_get $my_turbine_blob ]"

# Set the blob length equal to the number of elements
turbine_blob_length_set $my_turbine_blob $num_elements
puts "turbine_blob_length: [ turbine_blob_length_get $my_turbine_blob ]"

# Set the blob pointer to the allocated pointer
turbine_blob_pointer_set $my_turbine_blob $test_ptr
puts "turbine_blob_ptr: [ turbine_blob_pointer_get $my_turbine_blob ]"

# Store something in index 0
blobutils_set_float $test_ptr 0 2.9

# cast to double *
set lookup_ptr [ blobutils_cast_to_dbl_ptr $test_ptr ]

set result [ blobutils_get_float $lookup_ptr 0 ]
puts "result: $result"

# Store something in index 1
blobutils_set_float $test_ptr 1 9.9

set result [ blobutils_get_float $lookup_ptr 1 ]
puts "result: $result"

# Store something in index 2
blobutils_set_float $test_ptr 2 4.9

set result [ blobutils_get_float $lookup_ptr 2 ]
puts "result: $result"

blobutils_destroy $my_turbine_blob