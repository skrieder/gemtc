all: 001 md sleep

001:
	stc -r $PWD 001_mdproxy.swift 001_mdproxy.tcl
test-001:
	turbine 001_mdproxy.tcl -np=100

md:
	stc -r $PWD test_gemtc_md.swift test_gemtc_md.tcl
multi-md:
	stc -r $PWD test_gemtc_md_multi.swift test_gemtc_md_multi.tcl

sleep:
	stc -r $PWD test_gemtc.swift test_gemtc.tcl
parallel:
	stc -r $PWD test_gemtc_parallel.swift 

clean:
	rm test_gemtc_md.tcl test_gemtc.tcl 001_mdproxy.tcl test_gemtc_md_multi.tcl test_gemtc_parallel.tcl

test-md:
	/usr/bin/time -f "%e" turbine test_gemtc_md.tcl -array_size=10
	
test-multi-md:
	turbine test_gemtc_md_multi.tcl

test-sleep:
	turbine test_gemtc.tcl

