#!/bin/bash

# Build the leaf package
#
# Environment variables:
#
# TCL_HOME: Tcl directory.  If not set, detect tclsh in path
# CUDA_HOME: CUDA directory with lib and include subdirectories
# EXM_INST: exm installation directory, with subdirectories turbine, lb, etc.
# GEMTC_STATIC: if set to a nonzero integer, build static gemtc lib
#               instead of shared object

set -x

# Set CC if desired
CC=${CC:-gcc}

# This could be a Makefile but I think it is better
# to use bash as a reference example. -Justin

LEAF_PKG=sleep
LEAF_I=${LEAF_PKG}.i
LEAF_SO=libtcl${LEAF_PKG}.so
LEAF_A=libtcl${LEAF_PKG}.a
LEAF_TCL=${LEAF_PKG}.tcl
LEAF_C=${LEAF_PKG}.c
LEAF_O=${LEAF_PKG}.o
# The SWIG-generated file:
WRAP_C=${LEAF_PKG}_wrap.c
LEAF_VERSION=0.0

# Default to home directory
EXM_INST=${EXM_INST:-$HOME}

if [ ! -d ${EXM_INST} ]; then
  echo "ExM installation directory $EXM_INST does not exist"
  exit 1
fi

C_UTILS_INST=${EXM_INST}/c-utils
TURBINE_INST=${EXM_INST}/turbine
ADLB_INST=${EXM_INST}/lb
STC_INST=${EXM_INST}/stc

INCLUDE_FLAGS="${C_UTILS_INST}/include"

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

if [ -z "$TCL_HOME" ]; then
  TCLSH=$( which tclsh )
  check "Could not find tclsh in PATH!"

  TCL_HOME=$( cd $( dirname ${TCLSH} )/.. ; /bin/pwd )
  check "Could not find Tcl installation!"
else
  TCLSH=""
fi
echo "using Tcl in ${TCL_HOME}"

#CUDA_HOME=/opt/nvidia/cudatoolkit/5.0.35
CUDA_HOME=${CUDA_HOME:-/usr/local/cuda}
if [ ! -d "$CUDA_HOME" ]; then
  echo "CUDA_HOME $CUDA_HOME not a directory"
  exit 1
fi
CUDA_LIB_DIR=${CUDA_HOME}/lib64
CUDA_INCLUDE_DIR=${CUDA_HOME}/include
echo "using CUDA in ${CUDA_HOME}"

TCL_CONFIG=${TCL_HOME}/unix/tclConfig.sh
# TCL_CONFIG=${TCL_HOME}/lib64/tclConfig.sh

[[ -f ${TCL_CONFIG} ]]
check "Could not read tclConfig.sh!"

# This loads many Tcl configuration variables
source ${TCL_CONFIG}
check "tclConfig.sh failed!"

if [ -z "${TCLSH}" ]; then
  TCLSH=${TCL_HOME}/bin/tclsh${TCL_VERSION}
fi
echo "using tclsh ${TCLSH}"


CFLAGS="-g -I . -I ${C_UTILS} -Wall"
if (( ! GEMTC_STATIC )); then
  CFLAGS="-fPIC $CFLAGS"
fi
SCOTTFLAGS="-std=c99 -I${CUDA_INCLUDE_DIR} -L. -lsleep"

# Compile the data implementation
${CC} ${CFLAGS} ${SCOTTFLAGS} -c ${LEAF_C} -o ${LEAF_O}
check

# Create the Tcl extension
swig -includeall -tcl ${LEAF_I}
check

# TODO: Figure out why this is necessary:
sed -i 's/Sleep_Init/Tclsleep_Init/' ${WRAP_C}

# Compile the Tcl extension
${CC} ${CFLAGS} ${SCOTTFLAGS} ${TCL_INCLUDE_SPEC} -c ${WRAP_C}
check

if (( GEMTC_STATIC ))
then
  # Build the Tcl extension as a static library
  ar rcs ${LEAF_A} ${LEAF_PKG}_wrap.o ${LEAF_O}
else
  # Build the Tcl extension as a shared library
  ${CC} -shared -o ${LEAF_SO} ${LEAF_PKG}_wrap.o ${LEAF_O} \
    -L ${PWD} -l sleep -Wl,-rpath -Wl,${PWD} -Wl,-rpath -Wl,${CUDA_LIB_DIR}
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
fi

exit 0
