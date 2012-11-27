#!/bin/bash

setup=2
workers=$1
mpi=$(($workers + $setup))
sleeptime=0
bound=$2

#echo "Setting Env Variables"
export TURBINE_CACHE_SIZE=0
export TURBINE_LOG=0
export TURBINE_USER_LIB=${PWD}

check()
{
  if [[ ${?} != 0 ]]
  then
    MSG=$1
    echo ${MSG}
  fi
}

STC=$( which stc )
check
#echo "using stc: ${STC}"

TURBINE=$( which turbine )
check
#echo "using turbine: ${TURBINE}"

STC_OUT=test-sleep1.tcl
${STC} test-sleep1.swift ${STC_OUT}
check

#echo "compiled to: ${STC_OUT}"

export ADLB_EXHAUST_TIME=1
export TURBINE_USER_LIB=${PWD}
${TURBINE} -l -n $mpi ${STC_OUT} -sleeptime=$sleeptime -bound=$bound
check

exit 0
