
jobs=10000
loopSize=100
for i in {1..4}
do
    matrixSide=32
    for k in {1..6}
    do
	echo "jobs: $jobs   matrixSide: $matrixSide   LoopSize: $loopSize"
	(/usr/bin/time -f "%e" ../../bin/APIMatrix $jobs $matrixSide $loopSize) 2>> logs/logAPIMatrixTest$i.txt

        matrixSide=$(($matrixSide+$matrixSide))
    done
done
