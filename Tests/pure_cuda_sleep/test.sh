#!/bin/bash
echo "start"
for i in {1..5}
do
    time ./sleep 1 1350&
done
echo "Done"