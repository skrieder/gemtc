make
./histogram 5 > histogram.dat
gnuplot format_histogram_time_cpu.p
gnuplot format_histogram_thrgh_cpu.p
scp plots/hist_throughput_cpu.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_cpu.png
scp plots/hist_time_cpu.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_cpu.png
make clean 
