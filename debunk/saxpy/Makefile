all:
	gcc -std=c99 test1.c -o test1
	gcc -std=c99 test2.c -o test2

tests:
	./test1
	./test2

test1:
	gcc -std=c99 test1.c -o test1

test2:
	gcc -std=c99 test2.c -o test2

test3:
	gcc -std=c99 test3.c -o test3

cuda:
	nvcc -arch=sm_20 test_saxpy.cu -o cuda_saxpy

clean:
	rm cuda_saxpy
	rm test1
	rm *~
