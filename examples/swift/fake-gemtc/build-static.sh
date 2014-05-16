#!/bin/bash

# Build the standalone binary for a script

# Set CC if desired
CC=${CC:-cc}

# Executables
SCRIPT_PREFIX="test_gemtc_parallel"
SCRIPT_SWIFT="${SCRIPT_PREFIX}.swift"
SCRIPT_TCL="${SCRIPT_PREFIX}.tcl"
SCRIPT_IC="${SCRIPT_PREFIX}.ic"
SCRIPT_MAIN_C="${SCRIPT_PREFIX}_main.c"
SCRIPT_MAIN="${SCRIPT_PREFIX}"
SCRIPT_MANIFEST="${SCRIPT_PREFIX}.manifest"

EXM_HOME=${EXM_HOME:-${HOME}/exm-dev}
GEMTC_HOME=${GEMTC_HOME:-${EXM_HOME}/gemtc}
TURBINE_HOME=${TURBINE_HOME:-${EXM_HOME}/turbine}
STC_HOME=${STC_HOME:-${EXM_HOME}/stc}
echo "using Turbine in ${TURBINE_HOME}"
echo "using STC in ${STC_HOME}"
echo "using GEMTC in ${GEMTC_HOME}"

MKSTATIC=${TURBINE_HOME}/scripts/mkstatic/mkstatic.tcl
if [ ! -x "$MKSTATIC" ]; then
  echo "Could not find mkstatic.tcl in Turbine install at $MKSTATIC"
  exit 1
fi


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


# Make Bash verbose
# set -x

# Get Turbine build vars, including TCL_VERSION, TCL_HOME, ADLB_HOME, C_UTILS_HOME
TURBINE_BUILD_CONFIG=${TURBINE_HOME}/scripts/turbine-build-config.sh
[[ -f ${TURBINE_BUILD_CONFIG} ]]
check "Could not read ${TURBINE_BUILD_CONFIG}!"
source ${TURBINE_BUILD_CONFIG}

echo "using Tcl in ${TCL_HOME}"
echo "using ADLB in ${ADLB_HOME}"
echo "using C_UTILS in ${C_UTILS_HOME}"

TCL_CONFIG=${TCL_HOME}/lib/tclConfig.sh
# TCL_CONFIG=${TCL_HOME}/lib64/tclConfig.sh

[[ -f ${TCL_CONFIG} ]]
check "Could not read tclConfig.sh!"

# This loads many Tcl configuration variables
source ${TCL_CONFIG}
check "tclConfig.sh failed!"

if [ -z "${TCLSH}" ]; then
  TCLSH=${TCL_HOME}/bin/tclsh${TCL_VERSION}
fi


set -x

# Compile the Swift code to tcl
${STC_HOME}/bin/stc -O3 -C ${SCRIPT_IC} ${SCRIPT_SWIFT} ${SCRIPT_TCL}
check
echo "compiled swift source to ${SCRIPT_TCL}."

# Create main Turbine program and package index, using compiled Tcl code
MKSTATIC_FLAGS="--include-sys-lib ${TCL_SYSLIB_DIR} --tcl-version ${TCL_VERSION}"
${MKSTATIC} ${SCRIPT_MANIFEST} ${MKSTATIC_FLAGS} -c ${SCRIPT_MAIN_C}
check
echo "created executable source ${SCRIPT_MAIN_C}"


# Compile the main program
CFLAGS="-std=c99 -g -dynamic -Wall"

INCLUDE_FLAGS="-I${C_UTILS_HOME}/include -I${GEMTC_HOME}"
GEMTC_LINK="-L${GEMTC_HOME} -lgemtc"
GEMTC_RPATH="-Wl,-rpath,${GEMTC_HOME}"

#MAIN_LINK_ARGS=$(${MKSTATIC} ${SCRIPT_MANIFEST} --link-objs --link-flags)
LINK_OBJS=$(${MKSTATIC} ${SCRIPT_MANIFEST} --link-objs )

# Try to link as much in as possible statically
# TODO: this is a little hacky and Cray specific
# TODO: we miss some libs
#TCL_LINK_ARGS="${TCL_LIB_SPEC} ${TCL_LIBS}"
TCL_LINK_ARGS="${TCL_LIB_SPEC} ${TCL_LIBS}"

STATIC_LINK_ARGS="-L${TURBINE_HOME}/lib -ltclturbinestatic -ltclturbine -ltclturbinestaticres \
                  -L${ADLB_HOME}/lib -ladlb -L${C_UTILS_HOME}/lib -lexmcutils "
DYNAMIC_LINK_ARGS="${GEMTC_LINK} ${TCL_LINK_ARGS}"
RPATH="${GEMTC_RPATH}"

${CC} ${CFLAGS} ${INCLUDE_FLAGS} \
      ${SCRIPT_MAIN_C} \
      ${LINK_OBJS} \
      -Wl,-Bstatic ${STATIC_LINK_ARGS} \
      -Wl,-Bdynamic ${DYNAMIC_LINK_ARGS} \
      ${RPATH} \
      -I. ${TURBINE_INCLUDES} ${GEMTC_INCLUDES} \
      -o ${SCRIPT_MAIN}
check

exit 0
