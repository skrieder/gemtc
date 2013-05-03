for i in {46..50}
do
    /usr/bin/time -f "%e" ./cilkFib $i 2>> out.txt
done