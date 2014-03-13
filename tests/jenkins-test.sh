#!/bin/bash

# This file will be run nightly by Jenkins.

# FORALL folders in this dir

# compile code in subdir

# Run the SAXPY Benchmark and Test
TEMP_DIR=$PWD
cd ../debunk/saxpy
./saxpy_benchmark_670.sh
cd $TEMP_DIR

# Exit to satisfy Jenkins, else build will fail
exit