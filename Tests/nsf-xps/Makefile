all: fib slow
fib:
	cilk++ fib.cilk -o cilkFib
slow:
	gcc slowfib.c -o slowFib
clean:
	rm -f cilkFib slowFib