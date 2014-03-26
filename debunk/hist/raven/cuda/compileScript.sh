#!/bin/bash

# Karthik Balasubramanian
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology

mv /lus/scratch/p01956/histogram.dat histogram.dat
gnuplot format_histogram_time_K20.p
gnuplot format_histogram_thrgh_K20.p
scp plots/hist_throughput_K20.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_K20.png
scp plots/hist_time_K20.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_K20.png
rm GeM*
