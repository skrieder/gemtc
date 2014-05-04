PPN=3
NODES=$1
#bound=$(($NODES * 2000))
bound=1
n=$(($PPN * $NODES))

echo "PPN:" $PPN
echo "NODES:" $NODES
echo "bound:" $bound
echo "nprocs:" $n

TURBINE_ENGINES=$NODES ADLB_SERVERS=$NODES QUEUE=normal BLUE_WATERS=true PPN=$PPN:xk turbine-aprun-run.zsh -n $n test_gemtc.tcl -bound=$bound -sleeptime=1
