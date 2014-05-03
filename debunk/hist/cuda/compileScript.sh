make
./histogram 5 10 > histogram.dat
gnuplot format_histogram_time_670.p
gnuplot format_histogram_thrgh_670.p
scp plots/hist_throughput_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_670.png
scp plots/hist_time_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_670.png
make clean 
