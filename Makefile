run:
	nvcc -g -G -arch=sm_21 main.cu -o bin/run
test:
	nvcc -g -G -arch=sm_21 main.cu -o bin/run
clean:
	rm ./bin/run
