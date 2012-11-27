#!/bin/bash

export TURBINE_USER_LIB=${PWD}

check()
{
  if [[ ${?} != 0 ]]
  then
    MSG=$1
    echo ${MSG}
  fi
}

TURBINE=$( which turbine )
echo "using: ${TURBINE}"

${TURBINE} -l -n 3 test-synth-turbine.tcl
