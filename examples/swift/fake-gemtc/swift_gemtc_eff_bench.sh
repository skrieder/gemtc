PPN=3
NODES=$1
SLEEPTIME=$3
bound=$2
#bound=$((60/$NODES*168))
n=$(($PPN * $NODES))

echo "PPN:" $PPN
echo "NODES:" $NODES
echo "bound:" $bound
echo "nprocs:" $n

FEATURE=xk TURBINE_ENGINES=$NODES ADLB_SERVERS=$NODES QUEUE=normal BLUE_WATERS=true PPN=$PPN turbine-aprun-run.zsh -n $n test_gemtc_parallel.tcl -bound=$bound -sleeptime=$SLEEPTIME
