#!/bin/sh

gcc -c hist.c || exit 1
gcc -c test_hist.c || exit 1
gcc -o hist.x test_hist.o hist.o || exit 1
