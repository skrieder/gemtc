run:
	nvcc -g -G -arch=sm_21 Tests/gemtc-benchmarking/APITestMain.cu -o bin/mainTest
test:
	nvcc -g -G -arch=sm_21 Tests/gemtc-benchmarking/APITestMain.cu -o bin/test
clean:
	rm ./bin/run
