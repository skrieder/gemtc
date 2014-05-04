export TURBINE_LOG=0
export TURBINE_DEBUG=0

echo "Cleaning Logs"
rm log.txt
bound=100000
sleep=10000
echo "Running Tests"
for j in {1..10}
do
    for i in {1..1}
    do
	echo "num_tasks: $bound"
	echo "sleep_time is: $sleep"
	/usr/bin/time -f %e turbine tgps.tcl -num_tasks=$bound -sleep_time=$sleep 2>> log.txt
    done
    sleep=$(($sleep + 10000))
#bound=$(($bound + 100000))
done
echo "Printing Logs"
cat log.txt