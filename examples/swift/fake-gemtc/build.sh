#!/bin/bash

# Build the leaf package

# This could be a Makefile but I think it is better
# to use bash as a reference example. -Justin

LEAF_PKG=gemtc
LEAF_I=${LEAF_PKG}.i
LEAF_SO=libtcl${LEAF_PKG}.so
LEAF_TCL=${LEAF_PKG}.tcl
LEAF_C=${LEAF_PKG}.c
LEAF_O=${LEAF_PKG}.o
# The SWIG-generated file:
WRAP_C=${LEAF_PKG}_wrap.c
LEAF_VERSION=0.0

C_UTILS=/home/skrieder/sfw/c-utils/include
# C_UTILS=${HOME}/sfw/c-utils/include
# C_UTILS=${HOME}/Public/c-utils/include

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

# Make Bash verbose
# set -x

TCL_CONFIG=${TCL_HOME}/unix/tclConfig.sh
# TCL_CONFIG=${TCL_HOME}/lib64/tclConfig.sh

[[ -f ${TCL_CONFIG} ]]
check "Could not read tclConfig.sh!"

# This loads many Tcl configuration variables
source ${TCL_CONFIG}
check "tclConfig.sh failed!"

CFLAGS="-fPIC -g -I . -I ${C_UTILS} -Wall"
SCOTTFLAGS="-std=c99 -I/usr/local/cuda/include -L. -lgemtc"

# Compile the data implementation
gcc ${CFLAGS} -c ${LEAF_C} -o ${LEAF_O}
check

# Create the Tcl extension
swig -includeall -tcl ${LEAF_I}
check

# TODO: Figure out why this is necessary:
sed -i 's/Gemtc_Init/Tclgemtc_Init/' ${WRAP_C}

# Compile the Tcl extension
gcc ${CFLAGS} ${TCL_INCLUDE_SPEC} -c ${WRAP_C}
check

CUDA_HOME=/usr/local/cuda/lib64

set -x
# Build the Tcl extension as a shared library
gcc -shared -o ${LEAF_SO} ${LEAF_PKG}_wrap.o ${LEAF_O} \
  -L ${PWD} -l gemtc -Wl,-rpath -Wl,${PWD} -Wl,-rpath -Wl,${CUDA_HOME}
check
echo "created library: ${LEAF_SO}"

# Make the Tcl package index
export LEAF_PKG LEAF_SO LEAF_TCL LEAF_VERSION
${TCLSH} make-package.tcl > pkgIndex.tcl
check
echo "created package."

# Tell the user what they need to do to run this
# Since we have modified engine.tcl, using stc -r is not sufficient to
# find the package
echo "Set in environment: TURBINE_USER_LIB=${PWD}"

exit 0
