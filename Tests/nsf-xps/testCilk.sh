for i in {1..50}
do
    /usr/bin/time -f "%e" ./cilkFib $i 2>> out.txt
done