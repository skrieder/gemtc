echo "Cleaning Logs"
rm log.txt
bound=100000
echo "Running Tests"
for j in {1..20}
do
    for i in {1..1}
    do
	echo "num_tasks: $bound"
	/usr/bin/time -f %e turbine tgps.tcl -num_tasks=$bound -sleep_time=0 2>> log.txt
    done
    bound=$(($bound + 100000))
done
echo "Printing Logs"
cat log.txt