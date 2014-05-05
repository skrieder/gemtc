
set name     $env(LEAF_PKG)
set version  $env(LEAF_VERSION)
set leaf_so  $env(LEAF_SO)
set leaf_tcl $env(LEAF_TCL)

puts [ ::pkg::create -name $name -version $version \
           -load $leaf_so -source $leaf_tcl ]
