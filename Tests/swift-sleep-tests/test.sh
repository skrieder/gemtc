echo "Removing Logs"
rm log.txt

echo "Setting Env Variables"
export TURBINE_CACHE_SIZE=0
export TURBINE_LOG=0

echo "Building TCL file"
stc 589-big-loop.swift 589-big-loop.tcl
workers=1
bound=$1
setup=2
mpi=$(($workers+$setup))

echo "Running Tests"
for j in {1..7}
do
    for i in {1..1}
    do
	/usr/bin/time -f %e turbine -n $mpi 589-big-loop.tcl -bound=$bound -sleeptime=0 2>> log.txt
    done
    workers=$(($workers + $workers))
    mpi=$(($workers + $setup))
done
echo "Printing Logs"
cat log.txt