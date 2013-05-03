#! /bin/bash                                                                                                                                                                       

# do the overall test, this many times
for i in {1..5}
do
    loopCount=1
#echo "Benchmarking cudaMemcpy" > logs/log$i.txt

    # 1 through 8 for the sleeptimes
    for k in {1..16}
    do
#	echo "Loop Count Equals: " $loopCount >> logs/log$i.txt

	# run the test
	(/usr/bin/time -f "%e" ./testMalloc $loopCount) 2>> logs/Malloc.txt
	# double the loop count
	loopCount=$(($loopCount*2))    
    done
done
