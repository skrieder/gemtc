#!/bin/bash

# Build the synth1 leaf package

# This could be a Makefile but I think it is better
# to use bash as a reference example. -Justin

mkdir -p build lib

LEAF_PKG="scicolsim"
LEAF_I=src/${LEAF_PKG}.i
LEAF_CXX=build/${LEAF_PKG}_wrap.cxx
LEAF_O=build/${LEAF_PKG}.o
LEAF_SO=lib/"lib${LEAF_PKG}.so"
LEAF_TCL=src/"${LEAF_PKG}.tcl"
LEAF_VERSION="0.0"

USER_CPP_FILE="optimizer-multi-loss.cpp"
USER_CPP=src/${USER_CPP_FILE}
USER_O=build/${USER_CPP_FILE%.cpp}.o

# Swift
USER_SWIFT_PREFIX=annealing-exm
USER_SWIFT_SCRIPT=src/${USER_SWIFT_PREFIX}.swift
USER_SWIFT_LOG=build/${USER_SWIFT_PREFIX}.stc.log
USER_SWIFT_IC=build/${USER_SWIFT_PREFIX}.ic
USER_SWIFT_TCL=lib/${USER_SWIFT_PREFIX}.tcl

CPP=${CPP:-g++}

check()
{
  CODE=${?}
  if [[ ${CODE} != 0 ]]
  then
    MSG=$1
    echo ${MSG}
    exit ${CODE}
  fi
  return 0
}

TCLSH=$( which tclsh )
check "Could not find tclsh in PATH!"

TCL_HOME=$( cd $( dirname ${TCLSH} )/.. ; /bin/pwd )
check "Could not find Tcl installation!"

echo "using Tcl in ${TCL_HOME}"

TCL_CONFIG=${TCL_HOME}/lib/tclConfig.sh
if [ ! -f ${TCL_CONFIG} ]; then
    TCL_CONFIG=${TCL_HOME}/lib64/tclConfig.sh
fi

[[ -f ${TCL_CONFIG} ]]
check "Could not read tclConfig.sh!"

# This loads many Tcl configuration variables
source ${TCL_CONFIG}
check "tclConfig.sh failed!"

set -x

# Create the Tcl extension
swig -c++ -tcl  -o ${LEAF_CXX} -module ${LEAF_PKG} ${LEAF_I}
check

# Boost directory: created by ./getboost.sh
BOOST=boost_1_47_0

if [[ ! -d ${BOOST} ]] ; then
  echo "Boost directory not found at ${BOOST}!."
  echo "Download Boost by running getboost.sh"
  exit 1
fi

# Compile the user code
nvcc -arch=sm_20 --compiler-options '-Wall -O2 -fPIC -Xcompiler' -g ${CFLAGS} -I ${BOOST} -o ${USER_O} -c ${USER_CPP}
#nvcc -arch=sm_20 --compiler-options '-Wall -O2 -fPIC -Xcompiler' -g ${CFLAGS} -I ${BOOST} -o ${USER_O} -c ${USER_CPP} -L/home/dgahlot/gemtc/ -llibgemtjc
check

# Compile the Tcl extension
${CPP} -Wall -O2 -fPIC -g ${CFLAGS} ${TCL_INCLUDE_SPEC} -o ${LEAF_O} -c ${LEAF_CXX}
check

# Build the Tcl extension as a shared library
${CPP} -g -shared -o ${LEAF_SO} ${LEAF_O} ${USER_O} ../../libgemtc.so
#${CPP} -g -shared -o ${LEAF_SO} ${LEAF_O} ${USER_O}
check
echo "created library: ${LEAF_SO}"

set +x

# Make the Tcl package index
export LEAF_PKG LEAF_SO LEAF_TCL LEAF_VERSION
${TCLSH} lib/make-package.tcl > lib/pkgIndex.tcl
check
echo "created package."

# Compile Swift script
stc -O3 -I src -l $USER_SWIFT_LOG -C $USER_SWIFT_IC \
    $USER_SWIFT_SCRIPT $USER_SWIFT_TCL
check
echo "compiled Swift script $USER_SWIFT_SCRIPT to $USER_SWIFT_TCL"

# Tell the user what they need to do to run this
echo "Set in environment: TURBINE_USER_LIB=${PWD}/lib"

exit 0
