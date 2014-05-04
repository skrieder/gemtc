set -x
stc -r $PWD -O3 test_gemtc.swift test_gemtc.tcl
stc -r $PWD -O3 test_gemtc_parallel.swift test_gemtc_parallel.tcl
stc -r $PWD -O3 tgps.swift tgps.tcl
set +x
