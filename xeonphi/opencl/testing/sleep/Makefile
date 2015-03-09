all:
	gcc -I /opt/AMDAPP/include -L /opt/AMDAPP/lib/x86_64 -o sleep0 sleeptask.c -lm -lrt -lOpenCL
	gcc -I /opt/AMDAPP/include -L /opt/AMDAPP/lib/x86_64 -o sleep1 concsleep.c -lm -lrt -lOpenCL

clean:
	rm sleep0
	rm sleep1
