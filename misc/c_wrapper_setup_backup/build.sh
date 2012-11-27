#!/bin/bash

# Build the sleep1 leaf package

# This could be a Makefile but I think it is better
# to use bash as a reference example. -Justin

LEAF_PKG=sleep1
LEAF_SO="libtcl${LEAF_PKG}.so"
LEAF_TCL="${LEAF_PKG}.tcl"

check()
{
  CODE=${?}
  if [[ ${CODE} != 0 ]]
  then
    MSG=$1
    echo ${MSG}
    exit ${CODE}
  fi
}

TCLSH=$( which tclsh )
check "Could not find tclsh in PATH!"

TCL_HOME=$( cd $( dirname ${TCLSH} )/.. ; /bin/pwd )
check "Could not find Tcl installation!"

echo "using Tcl in ${TCL_HOME}"

TCL_CONFIG=${TCL_HOME}/lib/tclConfig.sh

[[ -f ${TCL_CONFIG} ]]
check "Could not read tclConfig.sh!"

# This loads many Tcl configuration variables
source ${TCL_CONFIG}
check "tclConfig.sh failed!"

# Scott is building some GeMTC items here!
# Step 1:
#echo "Step 1: Compiling our library source into PIC."
#echo "gcc -fPIC -c gemtc_setup.c -o gemtc_setup.o"
#gcc -fPIC -c gemtc_setup.c -o gemtc_setup.o
# Step 2:
#echo "Step 2: Turn the object file into a shared library." 
#echo "gcc -shared -o libgemtc.so gemtc_setup.o -L. -ltest"
#gcc -shared -o libgemtc.so gemtc_setup.o -L. -ltest
# Step 3:
#echo "Step 3: Linking with a shared library." 
#echo "gcc -L. -Wall -o test gemtc_setup.c -lgemtc"
#gcc -L. -Wall -o test gemtc_setup.c -lgemtc

# Compile the Tcl extension
gcc -fPIC ${TCL_INCLUDE_SPEC} -c ${LEAF_PKG}.c
check

# Build the Tcl extension as a shared library
gcc -shared -o ${LEAF_SO} ${LEAF_PKG}.o #-L. -ltest -lgemtc
check
echo "created library: ${LEAF_SO}"

# Make the Tcl package index
export LEAF_PKG LEAF_SO LEAF_TCL
${TCLSH} make-package.tcl > pkgIndex.tcl
check
echo "created package."

# Tell the user what they need to do to run this
echo "Set in environment: TURBINE_USER_LIB=${PWD}"

exit 0