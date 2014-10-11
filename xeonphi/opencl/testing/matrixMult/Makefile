all:
	gcc -I /opt/AMDAPP/include -L /opt/AMDAPP/lib/x86_64 -o matm matmul.c -lm -lrt -lOpenCL
	gcc -I /opt/AMDAPP/include -L /opt/AMDAPP/lib/x86_64 -o kmat kmat.c -lm -lrt -lOpenCL

clean:
	rm matm
	rm kmat
