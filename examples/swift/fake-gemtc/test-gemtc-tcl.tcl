### USAGE

# 1) Help Tcl find the pkgIndex file:
# export TCLLIBPATH=$PWD
# 2) Help the loader find the other .so and CUDA
# export LD_LIBRARY_PATH=$PWD:$CUDA
#   On Breadboard and skrieder, CUDA is in /usr/local/cuda/lib64
#       export LD_LIBRARY_PATH=$PWD:/usr/local/cuda/lib64

package require gemtc 0.0

### GEMTC
puts GEMTC

## Call setup once at the start
GEMTC_Setup 12800

#set size sizeof(int)
set sizeOfInt [ GEMTC_SizeOfInt ]
puts "Size of Int is: $sizeOfInt"

set h_sleeptime_ptr [ GEMTC_CPUMalloc $sizeOfInt ]
puts "h_sleeptime_ptr: $h_sleeptime_ptr"

GEMTC_CPU_SetInt $h_sleeptime_ptr 1

## Allocate an int
set d_sleeptime [ GEMTC_GPUMalloc $sizeOfInt ]

puts "d_sleeptime is: $d_sleeptime"

# exit

puts "Starting memcpy from tcl"
## GEMTC_MemcpyHostToDevice *host *device sizeof(int)
GEMTC_MemcpyHostToDevice $d_sleeptime $h_sleeptime_ptr $sizeOfInt

puts "Starting push from tcl"
## GEMTC_Push Type Threads ID *d_params
GEMTC_Push 0 32 1 $d_sleeptime

#set result [ GEMTC_Poll ]
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
while { $h_ID_value == -1 } {
    # nothing completed                                                           
    puts "nothing completed"
    # delay for debugging                                                 
    after 100
    GEMTC_Poll $h_ID_ptr $d_params_ptr_ptr
    puts "called poll again"                                         
    set h_ID_value [ GEMTC_CPU_GetInt $h_ID_ptr ]

}

puts "result is: $h_ID_value"
#GEMTC_TestResult

puts "copy back"
GEMTC_MemcpyDeviceToHost $h_sleeptime_ptr $d_sleeptime $sizeOfInt

puts "free device and host"
GEMTC_GPUFree $d_sleeptime
GEMTC_CPUFree $h_sleeptime_ptr

puts "cleanup"
GEMTC_Cleanup
