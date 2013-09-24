#!/bin/bash


qsub -A ATPESC2013 -q Q.ATPESC2013 -t 10 -n 32 -O LOG2 --mode script ./jobscript.sh










