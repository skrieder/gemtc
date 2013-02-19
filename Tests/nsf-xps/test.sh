for i in {1..45}
do
    /usr/bin/time -f "%e" ./slowFib $i
done