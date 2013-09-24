#!/bin/bash


# -p is mode (how many MPI ranks per node)
# --np is number of ranks

runjob -p 16 --np 32 --block $COBALT_PARTNAME : hellompi2


# to add environment variables and program command-line arguments
# runjob -p 16 --np 32 --block $COBALT_PARTNAME --envs FOO=lions BAR=tigers BAZ=bears : hellompi arg1 arg2


echo End of jobscript2.sh

# Important - return a meaningful exit status
exit 0





