#!/bin/bash

# Karthik Balasubramanian
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology
mv /lus/scratch/p01956/histogram.dat histogram.dat
gnuplot format_histogram_time_raven.p
gnuplot format_histogram_thrgh_raven.p
scp plots/hist_throughput_raven.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_throughput_raven.png
scp plots/hist_time_raven.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/hist_time_raven.png
make clean
rm GeM*
