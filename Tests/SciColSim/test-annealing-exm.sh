#!/usr/bin/env bash

# Test the annealing loop on local machine

TCL_SCRIPT=lib/annealing-exm.tcl

export TURBINE_USER_LIB=`pwd`

export TURBINE_ENGINES=${TURBINE_ENGINES:-1}
export ADLB_SERVERS=${ADLB_SERVERS:-1}
#TURBINE_WORKERS=${TURBINE_WORKDS:-2}
TURBINE_WORKERS=1
PROCS=$(( $TURBINE_ENGINES + $ADLB_SERVERS + $TURBINE_WORKERS ))

OUTPUT_DIR=$(pwd)/test
OUTPUT_PREFIX=scicolsim
mkdir -p ${OUTPUT_DIR}

i=1
OUTPUT=${OUTPUT_DIR}/${OUTPUT_PREFIX}.out
while [ -f ${OUTPUT} ]; do
  OUTPUT=${OUTPUT_DIR}/${OUTPUT_PREFIX}.${i}.out
  i=$((i+1))
done


{
  echo "TURBINE_ENGINES: $TURBINE_ENGINES"
  echo "ADLB_SERVERS:    $ADLB_SERVERS"
  echo "TURBINE_WORKERS: $TURBINE_WORKERS"
  echo "PROCS:           $PROCS"
  echo
} > $OUTPUT

export LOGGING=0
export TURBINE_DEBUG=0
export ADLB_DEBUG=0

EVORERUNS=10
NREPS=1
N_EPOCHS=10
# N_EPOCHS=20
GRAPH_FILE=data/movie_graph.txt

export TURBINE_USER_LIB=`pwd`
turbine -l -n ${PROCS} ${TCL_SCRIPT} "$@" \
        --reruns_per_task=2 \
        `source anneal-mode.sh FAST_TEST` \
        --graph_file=`pwd`/${GRAPH_FILE} > ${OUTPUT}

RC=$?
if [ "$RC" == 0 ]; then
  echo "Finished run.  Success return code."
else
  echo "Finished run.  Error return code ${RC}."
fi

# # | tee -a $OUTPUT | grep -E '^tr:|^trace:'
# if [ $? -ne 0 ] ; then
#     echo 1>&2 RUNTIME ERROR
#     exit 1
# fi
# ./annealing-log-analyse.sh annealing-exm.out
