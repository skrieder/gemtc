#!/bin/bash

# Karthik Balasubramanian	
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology


make
./histogram 5 1 > histogram.dat
gnuplot format_histogram_time_670.p
gnuplot format_histogram_thrgh_670.p
scp plots/hist_throughput_GemTC_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_GemTC_670.png
scp plots/hist_time_GemTC_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_GemTC_670.png


make clean 
