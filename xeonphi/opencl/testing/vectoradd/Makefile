all:
	gcc -I /opt/AMDAPP/include -L /opt/AMDAPP/lib/x86_64 -o vect vectoradd.c -lm -lrt -lOpenCL
	gcc -I /opt/AMDAPP/include -L /opt/AMDAPP/lib/x86_64 -o mvect device.c -lm -lrt -lOpenCL

clean:
	rm vect
	rm mvect
