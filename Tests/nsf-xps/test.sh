for i in {1..40}
do
    /usr/bin/time -f "%e" ./slowFib $i
done