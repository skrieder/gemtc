### USAGE

# 1) Help Tcl find gemtc and turbine:
# export TCLLIBPATH=" . /home/wozniak/Public/turbine/lib"
# 2) Help the loader find the other .so and CUDA
# export LD_LIBRARY_PATH=$PWD:$CUDA
#   On Breadboard and skrieder, CUDA is in /usr/local/cuda/lib64
#       export LD_LIBRARY_PATH=$PWD:/usr/local/cuda/lib64

package require gemtc 0.0
package require turbine

## Call setup once at the start
GEMTC_Setup 12800

# Get Sizes
set sizeOfInt [ GEMTC_SizeOfInt ]
set sizeOfLongInt [ GEMTC_SizeOfLongInt ]
set sizeOfDouble [ GEMTC_SizeOfDouble ]
set sizeOfFloat [ blobutils_sizeof_float ]
puts "Sizes:\n\tInt: $sizeOfInt \n\tLong Int: $sizeOfLongInt\n\tDouble: $sizeOfDouble\n\tFloat: $sizeOfFloat"

set h_np_ptr [ GEMTC_CPUMalloc $sizeOfFloat ] 
set h_nd_ptr [ GEMTC_CPUMalloc $sizeOfFloat ]
set h_mass_ptr [ GEMTC_CPUMalloc $sizeOfFloat ]
GEMTC_CPU_SetLongInt $h_np_ptr 10
GEMTC_CPU_SetLongInt $h_nd_ptr 2
GEMTC_CPU_SetDouble $h_mass_ptr 1.0

set h_np_value [ GEMTC_CPU_GetLongInt $h_np_ptr ]
set h_nd_value [ GEMTC_CPU_GetLongInt $h_nd_ptr ]
puts "NP is: $h_np_value"
puts "ND is: $h_nd_value"
set h_a_size_value [ expr "$h_np_value * $h_nd_value"]
puts "A_Size: $h_a_size_value"
set h_a_mem_value [ expr "$h_a_size_value * $sizeOfDouble"]
puts "A_mem: $h_a_mem_value"

# Now we need to allocate device arrays
set mem_needed [ expr "$sizeOfLongInt * 2 + $sizeOfDouble + $h_a_mem_value * 6" ]
puts "Mem Needed: $mem_needed"

# Get a void pointer
set h_table_ptr [ GEMTC_GetVoidPointerWithSize $mem_needed ]
puts "h_table_ptr is: $h_table_ptr"

# Set the table pointer
SetVoidPointerWithOffset $h_table_ptr $h_np_ptr $sizeOfLongInt 0
SetVoidPointerWithOffset $h_table_ptr $h_nd_ptr $sizeOfLongInt $sizeOfLongInt
SetVoidPointerWithOffset $h_table_ptr $h_mass_ptr $sizeOfDouble [expr "$sizeOfLongInt * 2"]

###Position Array###
# get a new blob, pointer, set blob details
set my_turbine_blob [ new_turbine_blob ]
set h_posArray_ptr [ blobutils_malloc $h_a_mem_value ]
turbine_blob_length_set $my_turbine_blob $h_a_size_value
turbine_blob_pointer_set $my_turbine_blob $h_posArray_ptr
puts "my_turbine_blob: $my_turbine_blob"
puts "blob_length: [ turbine_blob_length_get $my_turbine_blob ]"
puts "h_posArray_ptr: $h_posArray_ptr"

# Fill position array with random doubles
GEMTC_FillPositionArray $h_posArray_ptr $h_a_size_value

###Other Array###
# get a new blob, pointer, set blob details
set my_other_turbine_blob [ new_turbine_blob ]
set h_dummyArray_ptr [ blobutils_malloc $h_a_mem_value ]
turbine_blob_length_set $my_other_turbine_blob $h_a_size_value
turbine_blob_pointer_set $my_other_turbine_blob $h_dummyArray_ptr
puts "my_other_turbine_blob: $my_other_turbine_blob"
puts "blob_length: [ turbine_blob_length_get $my_other_turbine_blob ]"
puts "h_dummyArray_ptr: $h_dummyArray_ptr"

# Fill other array with zeros
GEMTC_ZeroDoubleArray $h_dummyArray_ptr $h_a_size_value

SetVoidPointerWithOffset $h_table_ptr $h_posArray_ptr $h_a_mem_value 24

for { set i 1 } { $i < 6 } { incr i } {
    SetVoidPointerWithOffset $h_table_ptr $h_dummyArray_ptr $h_a_mem_value [expr "24 + $i * $h_a_mem_value"]
}

#Uncomment the line below to print all the parameters. 
#dumpParams $h_table_ptr

set d_table_ptr [ GEMTC_GPUMalloc $mem_needed ]
puts "d_table_ptr: $d_table_ptr"
## GEMTC_MemcpyHostToDevice *host *device sizeof(int)
puts "Starting memcpy to dev from tcl"
GEMTC_MemcpyHostToDevice $d_table_ptr $h_table_ptr $mem_needed

puts "Dumping parameters"
dumpParams $h_table_ptr


puts "Starting push from tcl"
GEMTC_Push 20 32 1 $d_table_ptr

# host test table
set h_result_table_ptr [ GEMTC_GetVoidPointerWithSize $mem_needed ]

# Allocate some pointers                                                         
set h_ID_ptr [ GEMTC_CPUMallocInt $sizeOfInt ]
set d_params_ptr [ GEMTC_CPUMallocVP $sizeOfInt ]
set d_params_ptr_ptr [ GEMTC_CPUMallocVPP $sizeOfInt ]
set h_params_ptr [ GEMTC_CPUMallocVP $sizeOfInt ]

# Call Poll
set h_ID_value -1
while { $h_ID_value == -1 } {
    after 100
    GEMTC_Poll $h_ID_ptr $d_params_ptr_ptr
    set h_ID_value [ GEMTC_CPU_GetInt $h_ID_ptr ]
}

puts "result is: $h_ID_value"

puts "copy back"
GEMTC_MemcpyDeviceToHost $h_result_table_ptr $d_table_ptr $mem_needed

dumpParams $h_result_table_ptr 

#puts "free device and host"
#GEMTC_GPUFree $d_sleeptime
#GEMTC_CPUFree $h_sleeptime_ptr

puts "cleanup"
GEMTC_Cleanup
