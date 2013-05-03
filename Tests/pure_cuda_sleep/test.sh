#!/bin/bash
echo "start"
#var = $1
for i in {1..65}
do
    /usr/bin/time -f %e ./sleep 1 0&
#    ./sleep 1 0&
done
echo "Done"