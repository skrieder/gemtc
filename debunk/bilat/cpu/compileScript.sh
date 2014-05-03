make
./filtering 4 1 > filtering.dat
gnuplot format_bilat_time_cpu.p
scp plots/bilat_time_cpu.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/bilat_time_cpu.png
make clean 
