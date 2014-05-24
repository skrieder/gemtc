
# Generated by stc version 0.2.0
# date                    : 2014/05/05 14:35:44
# Turbine version         : 0.3.0
# Input filename          : /home/karthik/gemtc/debunk/hist/swift/cuda/test_hist_n.swift
# Output filename         : /home/karthik/gemtc/debunk/hist/swift/cuda
# STC home                : /home/skrieder/sfw/stc
# Turbine home            : /home/skrieder/sfw/turbine
# Compiler settings:
# stc.auto-declare              : true
# stc.c_preprocess              : true
# stc.checkpointing             : true
# stc.codegen.no-stack          : true
# stc.codegen.no-stack-vars     : true
# stc.compiler-debug            : true
# stc.debugging                 : COMMENTS
# stc.ic.output-file            : 
# stc.input_filename            : test_hist_n.swift
# stc.log.file                  : 
# stc.log.trace                 : false
# stc.must_pass_wait_vars       : true
# stc.opt.algebra               : false
# stc.opt.array-build           : true
# stc.opt.batch-refcounts       : true
# stc.opt.cancel-refcounts      : true
# stc.opt.constant-fold         : true
# stc.opt.controlflow-fusion    : true
# stc.opt.dead-code-elim        : true
# stc.opt.disable-asserts       : false
# stc.opt.expand-dataflow-ops   : true
# stc.opt.expand-loop-threshold-insts: 256
# stc.opt.expand-loop-threshold-iters: 16
# stc.opt.expand-loops          : true
# stc.opt.finalized-var         : true
# stc.opt.flatten-nested        : true
# stc.opt.full-unroll           : false
# stc.opt.function-inline       : false
# stc.opt.function-inline-threshold: 500
# stc.opt.function-signature    : true
# stc.opt.hoist                 : true
# stc.opt.hoist-refcounts       : true
# stc.opt.loop-simplify         : true
# stc.opt.max-iterations        : 10
# stc.opt.merge-refcounts       : true
# stc.opt.piggyback-refcounts   : true
# stc.opt.pipeline              : false
# stc.opt.reorder-insts         : false
# stc.opt.shared-constants      : true
# stc.opt.unroll-loop-threshold-insts: 192
# stc.opt.unroll-loop-threshold-iters: 8
# stc.opt.unroll-loops          : true
# stc.opt.value-number          : true
# stc.opt.wait-coalesce         : true
# stc.output_filename           : 
# stc.preproc.force-cpp         : false
# stc.preproc.force-gcc         : false
# stc.preprocess_only           : false
# stc.profile                   : false
# stc.refcounting               : true
# stc.rpath                     : 
# stc.stc_home                  : /home/skrieder/sfw/stc
# stc.turbine.version           : 0.3.0
# stc.turbine_home              : /home/skrieder/sfw/turbine
# stc.version                   : 0.2.0

# Metadata:

package require turbine 0.3.0
namespace import turbine::*


proc swift:constants {  } {
    turbine::c::log "function:swift:constants"
}

package require hist 0.0


proc swift:main {  } {
    turbine::c::log "enter function: main"
    set stack 0
    # Var: file u:data test_hist_n.swift:main():8:2
    # Var: blob u:v test_hist_n.swift:main():9:2
    # Var: $file optv:data VALUE_OF [file:data]
    lassign [ adlb::multicreate [ list blob 1 ] ] u:v
    turbine::c::log "allocated u:v=<${u:v}>"
    turbine::allocate_file2 u:data "" 1
    # Swift l.8: assigning expression to data
    set optv:data [ turbine::input_file_local "input.data" ]
    turbine::set_filename_val ${u:data} "input.data"
    turbine::set_file ${u:data} optv:data
    # Swift l.9: assigning expression to v
    turbine::blob_read [ list ${u:v} ] [ list ${u:data} ]
    # Swift l.10: assigning expression to TEST
    # Swift l.13: assigning expression to s
    # Swift l.14 evaluating  expression and throwing away 1 results
    turbine::rule [ list ${u:v} ] "main-optmerged ${stack} ${u:v}"
    turbine::decr_local_file_refcount optv:data
}


proc main-optmerged { stack u:v } {
    # Var: $blob optv:v VALUE_OF [blob:v]
    # Var: $blob optv:s:1 VALUE_OF [blob:s:1]
    # Var: $blob optv:s:2 VALUE_OF [blob:s:2]
    # Var: $blob optv:s:3 VALUE_OF [blob:s:3]
    # Var: $blob optv:s:4 VALUE_OF [blob:s:4]
    # Var: $blob optv:s:5 VALUE_OF [blob:s:5]
    # Var: $blob optv:s:6 VALUE_OF [blob:s:6]
    # Var: $blob optv:s:7 VALUE_OF [blob:s:7]
    # Var: $blob optv:s:8 VALUE_OF [blob:s:8]
    # Var: $blob optv:s:9 VALUE_OF [blob:s:9]
    # Var: $blob optv:s:10 VALUE_OF [blob:s:10]
    set optv:v [ turbine::retrieve_blob ${u:v} 1 ]
    set optv:s:1 [ hist::hist_tcl ${optv:v} ]
    set optv:s:2 [ hist::hist_tcl ${optv:v} ]
    set optv:s:3 [ hist::hist_tcl ${optv:v} ]
    set optv:s:4 [ hist::hist_tcl ${optv:v} ]
    set optv:s:5 [ hist::hist_tcl ${optv:v} ]
    set optv:s:6 [ hist::hist_tcl ${optv:v} ]
    set optv:s:7 [ hist::hist_tcl ${optv:v} ]
    set optv:s:8 [ hist::hist_tcl ${optv:v} ]
    set optv:s:9 [ hist::hist_tcl ${optv:v} ]
    set optv:s:10 [ hist::hist_tcl ${optv:v} ]
    turbine::free_local_blob ${optv:v}
    turbine::free_local_blob ${optv:s:1}
    turbine::free_local_blob ${optv:s:2}
    turbine::free_local_blob ${optv:s:3}
    turbine::free_local_blob ${optv:s:4}
    turbine::free_local_blob ${optv:s:5}
    turbine::free_local_blob ${optv:s:6}
    turbine::free_local_blob ${optv:s:7}
    turbine::free_local_blob ${optv:s:8}
    turbine::free_local_blob ${optv:s:9}
    turbine::free_local_blob ${optv:s:10}
}


proc f:hist { stack u:sum u:v } {
    turbine::c::log "enter function: hist"
    turbine::read_refcount_incr ${u:v} 1
    turbine::rule [ list ${u:v} ] "hist-argwait ${stack} ${u:v} ${u:sum}"
}


proc hist-argwait { stack u:v u:sum } {
    # Var: $blob v:v VALUE_OF [blob:v]
    # Var: $blob v:sum VALUE_OF [blob:sum]
    set v:v [ turbine::retrieve_blob ${u:v} 1 ]
    set v:sum [ hist::hist_tcl ${v:v} ]
    turbine::store_blob ${u:sum} ${v:sum}
    turbine::free_local_blob ${v:v}
    turbine::free_local_blob ${v:sum}
}

turbine::defaults
turbine::init $engines $servers "Swift"
turbine::enable_read_refcount
turbine::xpt_init
turbine::check_constants "WORKER" ${turbine::WORK_TASK} 0 "CONTROL" ${turbine::CONTROL_TASK} 1 "ADLB_RANK_ANY" ${adlb::RANK_ANY} -100
turbine::start swift:main swift:constants
turbine::finalize
turbine::xpt_finalize
